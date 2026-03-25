from rest_framework import serializers

from .models import Task


class TaskSerializer(serializers.ModelSerializer):
    is_blocked = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Task
        fields = [
            'id',
            'title',
            'description',
            'due_date',
            'status',
            'blocked_by',
            'is_blocked',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'is_blocked', 'created_at', 'updated_at']

    def validate(self, attrs):
        instance = self.instance
        blocked_by = attrs.get('blocked_by')

        if blocked_by and instance and blocked_by.pk == instance.pk:
            raise serializers.ValidationError(
                {'blocked_by': 'A task cannot be blocked by itself.'}
            )

        if blocked_by and instance and self._forms_cycle(instance.pk, blocked_by):
            raise serializers.ValidationError(
                {'blocked_by': 'Circular dependency is not allowed.'}
            )

        return attrs

    def get_is_blocked(self, obj):
        return obj.is_blocked

    def _forms_cycle(self, instance_id, blocked_by):
        current = blocked_by
        visited = set()

        while current is not None:
            if current.pk == instance_id:
                return True
            if current.pk in visited:
                return False
            visited.add(current.pk)
            current = current.blocked_by

        return False
