from datetime import date
from unittest.mock import patch

from django.core.exceptions import ValidationError
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Task, TaskStatus


class TaskModelTests(APITestCase):
	def test_rejects_self_blocking(self):
		task = Task.objects.create(
			title='Parent Task',
			description='Parent description',
			due_date=date(2026, 4, 1),
			status=TaskStatus.TO_DO,
		)

		task.blocked_by = task
		with self.assertRaises(ValidationError):
			task.save()


class TaskApiTests(APITestCase):
	def setUp(self):
		self.list_url = reverse('task-list')

	@patch('tasks.views.time.sleep')
	def test_create_task_calls_delay(self, mocked_sleep):
		payload = {
			'title': 'Prepare release notes',
			'description': 'Draft notes for sprint handover',
			'due_date': '2026-03-30',
			'status': TaskStatus.TO_DO,
			'blocked_by': None,
		}

		response = self.client.post(self.list_url, payload, format='json')

		self.assertEqual(response.status_code, status.HTTP_201_CREATED)
		mocked_sleep.assert_called_once_with(2)

	@patch('tasks.views.time.sleep')
	def test_update_task_calls_delay(self, mocked_sleep):
		task = Task.objects.create(
			title='Task One',
			description='Initial description',
			due_date=date(2026, 4, 1),
			status=TaskStatus.TO_DO,
		)

		response = self.client.patch(
			reverse('task-detail', kwargs={'pk': task.pk}),
			{'status': TaskStatus.DONE},
			format='json',
		)

		self.assertEqual(response.status_code, status.HTTP_200_OK)
		mocked_sleep.assert_called_once_with(2)

	def test_search_and_status_filter(self):
		Task.objects.create(
			title='Setup backend API',
			description='Build serializers and views',
			due_date=date(2026, 4, 1),
			status=TaskStatus.IN_PROGRESS,
		)
		Task.objects.create(
			title='Write Flutter widgets',
			description='Create list and form views',
			due_date=date(2026, 4, 2),
			status=TaskStatus.TO_DO,
		)

		response = self.client.get(self.list_url, {'q': 'backend', 'status': TaskStatus.IN_PROGRESS})

		self.assertEqual(response.status_code, status.HTTP_200_OK)
		self.assertEqual(len(response.data), 1)
		self.assertEqual(response.data[0]['title'], 'Setup backend API')

	def test_delete_blocker_task_is_rejected(self):
		blocker = Task.objects.create(
			title='Parent',
			description='Must complete first',
			due_date=date(2026, 4, 1),
			status=TaskStatus.TO_DO,
		)
		Task.objects.create(
			title='Child',
			description='Depends on parent',
			due_date=date(2026, 4, 2),
			status=TaskStatus.TO_DO,
			blocked_by=blocker,
		)

		response = self.client.delete(reverse('task-detail', kwargs={'pk': blocker.pk}))

		self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
		self.assertIn('depend on it', response.data['detail'])
