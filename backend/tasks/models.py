from django.core.exceptions import ValidationError
from django.db import models


class TaskStatus(models.TextChoices):
	TO_DO = 'TO_DO', 'To-Do'
	IN_PROGRESS = 'IN_PROGRESS', 'In Progress'
	DONE = 'DONE', 'Done'


class Task(models.Model):
	title = models.CharField(max_length=255)
	description = models.TextField()
	due_date = models.DateField()
	status = models.CharField(max_length=20, choices=TaskStatus.choices)
	blocked_by = models.ForeignKey(
		'self',
		on_delete=models.PROTECT,
		related_name='dependents',
		null=True,
		blank=True,
	)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['due_date', 'id']

	def __str__(self):
		return self.title

	@property
	def is_blocked(self):
		return bool(self.blocked_by and self.blocked_by.status != TaskStatus.DONE)

	def clean(self):
		if self.blocked_by_id and self.pk and self.blocked_by_id == self.pk:
			raise ValidationError({'blocked_by': 'A task cannot be blocked by itself.'})

		# Walk the dependency chain to reject circular relationships.
		visited = set()
		current = self.blocked_by
		while current is not None:
			if self.pk and current.pk == self.pk:
				raise ValidationError({'blocked_by': 'Circular dependency is not allowed.'})
			if current.pk in visited:
				break
			visited.add(current.pk)
			current = current.blocked_by

	def save(self, *args, **kwargs):
		self.full_clean()
		super().save(*args, **kwargs)
