from django.urls import path
from . import views

urlpatterns = [
    path('signup/', views.register_view, name='signup'),
    path('login/', views.login_view, name='login'),
    path('posts/', views.list_blog_posts, name='list_blog_posts'),
    path('posts/<int:pk>/', views.blog_post_detail, name='blog_post_detail'),
    path('posts/create/', views.create_blog_post, name='create_blog_post'),
]
