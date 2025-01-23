import React from "react";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import Home from "./pages/Home";
import CreatePost from "./pages/CreatePost";
import PostDetail from "./pages/PostDetail";
import AppLayout from "./components/AppLayout";
import BlogPostList from "./components/BlogPostList";
import Register from "./pages/Register";
import LoginPage from "./pages/LoginPage";

const App = () => {
  return (
    <BrowserRouter>
      <Routes>
        {/* <Route path="/" element={<Home />} />
        <Route path="/create" element={<CreatePost />} />
        <Route path="/post/:id" element={<PostDetail />} /> */}
        <Route path="/" element={<AppLayout />}>
          <Route index element={<BlogPostList />} />
          <Route path="create" element={<CreatePost />} />
          <Route path="post/:id" element={<PostDetail />} />
        </Route>
        <Route path="signup" element={<Register />} />
        <Route path="login" element={<LoginPage />} />
      </Routes>
         {/* Toast notifications */}
         <ToastContainer
            position="top-right"
            autoClose={5000}
            hideProgressBar
            newestOnTop={false}
            closeOnClick
            rtl={false}
            pauseOnFocusLoss
            draggable
            pauseOnHover
            className={"font-poppins"}
            successClassName="bg-accent-1"
          />

    </BrowserRouter>
  );
};

export default App;
