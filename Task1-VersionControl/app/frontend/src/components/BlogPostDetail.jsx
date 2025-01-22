import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import api from "../services/api";

const BlogPostDetail = () => {
  const { id } = useParams();
  const [post, setPost] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchPost = async () => {
      try {
        const response = await api.get(`/posts/${id}/`);
        setPost(response.data);
      } catch (error) {
        console.error("Error fetching post:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchPost();
  }, [id]);

  return (
    <div className="bg-gray-50 dark:bg-slate-900 py-10 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto bg-white dark:bg-gray-800 shadow-lg rounded-lg p-6 sm:p-8">
        {/* Back Arrow Button */}
        <button
          onClick={() => window.history.back()}
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

        {loading ? (
          <div className="space-y-6 animate-pulse">
            {/* Title Skeleton */}
            <div className="h-8 bg-gray-300 dark:bg-gray-700 rounded w-3/4"></div>
            {/* Content Skeleton */}
            <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-full"></div>
            <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-5/6"></div>
            <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-4/6"></div>
            {/* Author Skeleton */}
            <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-1/3 mt-4"></div>
          </div>
        ) : (
          post && (
            <div>
              <h1 className="text-3xl font-bold text-gray-800 dark:text-gray-200 mb-6">
                {post.title}
              </h1>
              <p className="text-gray-700 dark:text-gray-300 text-lg leading-relaxed mb-4">
                {post.content}
              </p>
              <small className="text-gray-500 dark:text-gray-400">
                <strong>Author:</strong> {post.author}
              </small>
            </div>
          )
        )}
      </div>
    </div>
  );
};

export default BlogPostDetail;
