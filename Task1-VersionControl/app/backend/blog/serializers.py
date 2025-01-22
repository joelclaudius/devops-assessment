from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth import authenticate
from .models import BlogPost



class RegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    username = serializers.CharField(required=True)

    class Meta:
        model = get_user_model()
        fields = ['username', 'email', 'password', 'is_staff', 'is_superuser']

    def create(self, validated_data):
        user = get_user_model().objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            is_staff=False,  # Default set to False
            is_superuser=False  # Default set to False
        )
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        user = authenticate(email=data['email'], password=data['password'])
        if user is None:
            raise serializers.ValidationError("Invalid credentials")
        self.context['user'] = user
        return data

class BlogPostSerializer(serializers.ModelSerializer):
    author = serializers.StringRelatedField()  # Use username instead of the whole CustomUser object

    class Meta:
        model = BlogPost
        fields = '__all__'
        


