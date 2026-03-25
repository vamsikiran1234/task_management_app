import time

from django.db.models import ProtectedError
from rest_framework import status, viewsets
from rest_framework.response import Response

from .models import Task
from .serializers import TaskSerializer


class TaskViewSet(viewsets.ModelViewSet):
	queryset = Task.objects.select_related('blocked_by').all()
	serializer_class = TaskSerializer

	def get_queryset(self):
		queryset = super().get_queryset()
		query = self.request.query_params.get('q', '').strip()
		status_filter = self.request.query_params.get('status', '').strip()

		if query:
			queryset = queryset.filter(title__icontains=query)

		if status_filter:
			queryset = queryset.filter(status=status_filter)

		return queryset

	def perform_create(self, serializer):
		time.sleep(2)
		serializer.save()

	def perform_update(self, serializer):
		time.sleep(2)
		serializer.save()

	def destroy(self, request, *args, **kwargs):
		instance = self.get_object()
		try:
			self.perform_destroy(instance)
		except ProtectedError:
			return Response(
				{'detail': 'Cannot delete task because other tasks depend on it.'},
				status=status.HTTP_400_BAD_REQUEST,
			)
		return Response(status=status.HTTP_204_NO_CONTENT)
