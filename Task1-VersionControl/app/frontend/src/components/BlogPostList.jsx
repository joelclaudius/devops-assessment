import React, { useEffect, useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { XIcon, PencilIcon } from "@heroicons/react/solid";
import axiosInstance from "../services/api";
import { AuthContext } from "../context/AuthContext";
import { toast } from "react-toastify";

const ConfirmationModal = ({ isOpen, onClose, onConfirm }) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex justify-center items-center z-50">
      <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-lg">
        <h2 className="text-xl font-semibold text-gray-800 dark:text-gray-100 mb-4">
          Are you sure you want to delete this post?
        </h2>
        <div className="flex justify-end space-x-4">
          <button
            onClick={onClose}
            className="bg-gray-400 dark:bg-gray-600 text-white py-2 px-4 rounded hover:bg-gray-500 dark:hover:bg-gray-700 transition duration-200"
          >
            No
          </button>
          <button
            onClick={onConfirm}
            className="bg-red-600 dark:bg-red-500 text-white py-2 px-4 rounded hover:bg-red-700 dark:hover:bg-red-600 transition duration-200"
          >
            Yes
          </button>
        </div>
      </div>
    </div>
  );
};

const BlogPostList = () => {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [postToDelete, setPostToDelete] = useState(null);
  const navigate = useNavigate();
  const { isAuthenticated, user } = useContext(AuthContext);

  useEffect(() => {
    const fetchPosts = async () => {
      try {
        const response = await axiosInstance.get("/posts/");
        // Sort posts by created_at in descending order
        const sortedPosts = response.data.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        setPosts(sortedPosts);
      } catch (error) {
        console.error("Error fetching posts:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchPosts();
  }, []);

  const handleDelete = (id) => {
    setPostToDelete(id);
    setIsModalOpen(true);
  };

  const confirmDelete = async () => {
    try {
      await axiosInstance.delete(`/posts/${postToDelete}/`);
      setPosts(posts.filter((post) => post.id !== postToDelete));
      toast.success("Post deleted successfully!");
    } catch (error) {
      console.error("Error deleting post:", error);
      toast.error("Failed to delete the post.");
    } finally {
      setIsModalOpen(false);
      setPostToDelete(null);
    }
  };

  const cancelDelete = () => {
    setIsModalOpen(false);
    setPostToDelete(null);
  };

  return (
    <div className="bg-gray-50 dark:bg-slate-800 py-10 px-5 flex items-center">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-3xl md:text-5xl font-extrabold text-gray-900 dark:text-gray-100 text-center mb-12">
          Latest Blog Posts
        </h1>
        {loading ? (
          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
            {Array.from({ length: 6 }).map((_, index) => (
              <div
                key={index}
                className="bg-white dark:bg-gray-800 p-8 rounded-lg shadow-md animate-pulse"
              >
                <div className="h-8 bg-gray-300 dark:bg-gray-700 rounded w-4/5 mb-6"></div>
                <div className="h-6 bg-gray-300 dark:bg-gray-700 rounded w-3/4 mb-4"></div>
                <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-5/6"></div>
              </div>
            ))}
          </div>
        ) : (
          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
            {posts.map((post) => {
              const isAuthorOrAdmin =
                isAuthenticated && (user?.is_staff || user?.username === post.author);
              return (
                <div
                  key={post.id}
                  className="relative bg-white dark:bg-gray-800 p-4 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200"
                >
                  {isAuthorOrAdmin && (
                    <button
                      onClick={() => handleDelete(post.id)}
                      className="absolute top-2 right-2 bg-red-600 text-white p-2 rounded-full hover:bg-red-700"
                      title="Delete Post"
                    >
                      <XIcon className="h-5 w-5" />
                    </button>
                  )}
                  <h2 className="text-3xl font-semibold text-gray-800 dark:text-gray-100 mb-2">
                    {post.title.length > 50
                      ? `${post.title.substring(0, 50)}...`
                      : post.title}
                  </h2>
                  <p className="text-gray-600 dark:text-gray-300 line-clamp-3 mb-2">
                    {post.content.length > 100
                      ? `${post.content.substring(0, 100)}...`
                      : post.content}
                  </p>
                  <div className="flex justify-between mt-4">
                    <button
                      onClick={() => navigate(`/post/${post.id}`)}
                      className="bg-blue-600 dark:bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-700 dark:hover:bg-blue-600 transition duration-200"
                    >
                      Read More
                    </button>
                    {isAuthorOrAdmin && (
                      <button
                        onClick={() => navigate(`/post/${post.id}`)}
                        className="absolute bottom-4 right-2 bg-yellow-500 text-white p-2 rounded-full hover:bg-red-700"
                        title="Edit Post"
                      >
                        <PencilIcon className="h-5 w-5" />
                      </button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      <ConfirmationModal
        isOpen={isModalOpen}
        onClose={cancelDelete}
        onConfirm={confirmDelete}
      />
    </div>
  );
};

export default BlogPostList;
