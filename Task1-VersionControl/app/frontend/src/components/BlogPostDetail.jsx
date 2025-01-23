import React, { useEffect, useState, useContext } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { XIcon, PencilIcon, CheckIcon, XCircleIcon } from "@heroicons/react/solid";
import axiosInstance from "../services/api";
import { AuthContext } from "../context/AuthContext";
import { toast } from "react-toastify";

const BlogPostDetail = () => {
  const [post, setPost] = useState(null);
  const [loading, setLoading] = useState(true);
  const [editMode, setEditMode] = useState(false);
  const [editedPost, setEditedPost] = useState({ title: "", content: "" });
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const navigate = useNavigate();
  const { id } = useParams();
  const { isAuthenticated, user } = useContext(AuthContext);

  useEffect(() => {
    const fetchPost = async () => {
      try {
        const response = await axiosInstance.get(`/posts/${id}/`);
        setPost(response.data);
        setEditedPost({ title: response.data.title, content: response.data.content });
      } catch (error) {
        console.error("Error fetching post details:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchPost();
  }, [id]);

  const handleEdit = () => {
    setEditMode(true);
  };

  const handleSave = async () => {
    try {
      await axiosInstance.put(`/posts/${id}/`, editedPost);
      setPost(editedPost);
      setEditMode(false);
      toast.success("Post updated successfully!");
    } catch (error) {
      console.error("Error saving post:", error);
      toast.error("Failed to update the post.");
    }
  };

  const handleDelete = async () => {
    try {
      await axiosInstance.delete(`/posts/${id}/`);
      navigate("/");
      toast.success("Post deleted successfully!");
    } catch (error) {
      console.error("Error deleting post:", error);
      toast.error("Failed to delete the post.");
    } finally {
      setShowDeleteConfirm(false);
    }
  };

  if (loading) {
    return (
      <div className="bg-gray-50 dark:bg-slate-800 py-10 px-5 flex items-center">
        <div className="max-w-6xl mx-auto w-full">
          <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-md animate-pulse">
            <div className="mb-6">
              <div className="h-10 bg-gray-300 dark:bg-gray-700 rounded w-3/4 mx-auto"></div>
            </div>
            <div className="mb-8">
              <div className="h-6 bg-gray-300 dark:bg-gray-700 rounded w-1/2 mx-auto"></div>
            </div>
            <div className="mb-6">
              <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-3/4 mx-auto"></div>
            </div>
            <div className="flex justify-center space-x-4">
              <div className="h-12 w-12 bg-gray-300 dark:bg-gray-700 rounded-full"></div>
              <div className="h-12 w-12 bg-gray-300 dark:bg-gray-700 rounded-full"></div>
              <div className="h-12 w-12 bg-gray-300 dark:bg-gray-700 rounded-full"></div>
            </div>
          </div>
        </div>
      </div>
    );
  }
  

  if (!post) {
    return <p>Post not found</p>;
  }

  const isAuthorOrAdmin = isAuthenticated && (user?.is_staff || user?.username === post?.author);

  return (
    <div className="bg-gray-50 dark:bg-slate-800 py-10 px-5 flex items-center">
      <div className="max-w-7xl mx-auto">
        <button
          onClick={() => navigate(-1)}
          className="absolute top-[70px] right-4 p-2 bg-blue-500 dark:bg-gray-800 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition"
          aria-label="Go Back"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-6 w-6 text-gray-800 dark:text-gray-200"
            fill="none"
            viewBox="0 0 24 24"
            stroke="white"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M15 19l-7-7m0 0l7-7m-7 7h18"
            />
          </svg>
        </button>

        <div className="relative bg-white dark:bg-gray-800 p-4 rounded-lg shadow-md max-w-2xl mx-auto">
          {isAuthorOrAdmin && (
            <div className="absolute top-2 right-2 space-y-2 sm:flex sm:flex-col md:flex-row md:space-y-0 md:space-x-2">
              {editMode ? (
                <>
                  <button
                    onClick={handleSave}
                    className="flex items-center justify-center bg-green-500 text-white p-3 md:p-4 rounded-full hover:bg-green-600 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
                    title="Save Changes"
                  >
                    <CheckIcon className="h-5 w-5 md:h-6 md:w-6" />
                  </button>
                  <button
                    onClick={() => setEditMode(false)}
                    className="flex items-center justify-center bg-red-600 text-white p-3 md:p-4 rounded-full hover:bg-red-700 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2"
                    title="Cancel Edit"
                  >
                    <XCircleIcon className="h-5 w-5 md:h-6 md:w-6" />
                  </button>
                </>
              ) : (
                <>
                  <button
                    onClick={handleEdit}
                    className="flex items-center justify-center bg-yellow-500 text-white p-3 md:p-4 rounded-full hover:bg-yellow-600 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2"
                    title="Edit Post"
                  >
                    <PencilIcon className="h-5 w-5 md:h-6 md:w-6" />
                  </button>
                  <button
                    onClick={() => setShowDeleteConfirm(true)}
                    className="flex items-center justify-center bg-red-600 text-white p-3 md:p-4 rounded-full hover:bg-red-700 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2"
                    title="Delete Post"
                  >
                    <XIcon className="h-5 w-5 md:h-6 md:w-6" />
                  </button>
                </>
              )}
            </div>
          )}

          {editMode ? (
            <div>
              <input
                type="text"
                value={editedPost.title}
                onChange={(e) =>
                  setEditedPost({ ...editedPost, title: e.target.value })
                }
                className="w-full text-3xl font-extrabold text-gray-900 dark:text-gray-100 mb-6 bg-transparent border-b border-gray-300 focus:outline-none"
              />
              <textarea
                value={editedPost.content}
                onChange={(e) =>
                  setEditedPost({ ...editedPost, content: e.target.value })
                }
                className="w-full text-gray-600 dark:text-gray-300 bg-transparent border-b border-gray-300 focus:outline-none"
                rows={10}
              />
            </div>
          ) : (
            <div>
              <h1 className="text-3xl font-extrabold text-gray-900 dark:text-gray-100 mb-6">
                {post.title}
              </h1>
              <p className="text-gray-600 dark:text-gray-300">{post.content}</p>
            </div>
          )}
        </div>
      </div>

      {/* Delete Confirmation Overlay */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 bg-gray-900 bg-opacity-50 flex justify-center items-center z-50">
          <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-lg">
            <h3 className="text-xl font-semibold text-gray-900 dark:text-gray-100 mb-4">Confirm Deletion</h3>
            <p className="text-gray-600 dark:text-gray-300 mb-6">
              Are you sure you want to delete this post?
            </p>
            <div className="flex justify-end space-x-4">
              <button
                onClick={() => setShowDeleteConfirm(false)}
                className="bg-gray-200 dark:bg-gray-700 text-gray-900 dark:text-gray-200 p-2 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600"
              >
                Cancel
              </button>
              <button
                onClick={handleDelete}
                className="bg-red-600 text-white p-2 rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2"
              >
                Confirm
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default BlogPostDetail;
