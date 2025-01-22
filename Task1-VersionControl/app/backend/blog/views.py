from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated, IsAdminUser, IsAuthenticatedOrReadOnly
from .models import BlogPost
from .serializers import BlogPostSerializer, RegistrationSerializer, LoginSerializer


@api_view(['POST'])
def register_view(request):
    serializer = RegistrationSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
def login_view(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.context['user']
        refresh = RefreshToken.for_user(user)
        return Response({
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        })
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
def list_blog_posts(request):
    """
    List all blog posts.
    """
    posts = BlogPost.objects.all()
    serializer = BlogPostSerializer(posts, many=True)
    return Response(serializer.data)


@api_view(['POST'])
def create_blog_post(request):
    """
    Create a new blog post.
    """
    if not request.user.is_authenticated:
        return Response({'error': 'Authentication credentials were not provided'}, status=status.HTTP_401_UNAUTHORIZED)
    serializer = BlogPostSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(author=request.user)  # Automatically assign the logged-in user as the author
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'DELETE'])
def blog_post_detail(request, pk):
    """
    Retrieve, update, or delete a blog post by ID.
    """
    post = BlogPost.objects.get(pk=pk)
    if not post:
        return Response({'error': 'Blog post not found'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = BlogPostSerializer(post)
        return Response(serializer.data)

    if request.method == 'PUT':
        if not request.user.is_authenticated:
            return Response({'error': 'Authentication credentials were not provided'}, status=status.HTTP_401_UNAUTHORIZED)
        if request.user.is_authenticated and (request.user.is_staff or post.author == request.user):
            serializer = BlogPostSerializer(post, data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)

    if request.method == 'DELETE':
        if not request.user.is_authenticated:
            return Response({'error': 'Authentication credentials were not provided'}, status=status.HTTP_401_UNAUTHORIZED)
        if request.user.is_authenticated and (request.user.is_staff or post.author == request.user):
            post.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
