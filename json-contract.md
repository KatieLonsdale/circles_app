# Backend API JSON Contract

## Authentication Endpoints

### Login
- **URL**: `/api/v0/sessions`
- **Method**: `POST`
- **URL Parameters**: None
- **Request Body**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response**:
  ```json
  {
    "token": "string",
    "user": {
      "data": {
        "id": "string",
        "type": "user",
        "attributes": {
          "id": "integer",
          "email": "string",
          "display_name": "string",
          "notification_frequency": "string"
        }
      }
    }
  }
  ```

### Authenticate User
- **URL**: `/api/v0/users/authenticate`
- **Method**: `POST`
- **URL Parameters**: None
- **Request Body**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "user",
      "attributes": {
        "id": "integer",
        "email": "string",
        "display_name": "string",
        "notification_frequency": "string"
      }
    }
  }
  ```

## User Endpoints

### Get All Users
- **URL**: `/api/v0/users`
- **Method**: `GET`
- **URL Parameters**: None
- **Request Body**: None
- **Response**:
  ```json
  {
    "data": [
      {
        "id": "string",
        "type": "user",
        "attributes": {
          "id": "integer",
          "email": "string",
          "display_name": "string"
        }
      }
    ]
  }
  ```

### Get User
- **URL**: `/api/v0/users/{id}`
- **Method**: `GET`
- **URL Parameters**: 
  - `id`: ID of the user
- **Request Body**: None
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "user",
      "attributes": {
        "id": "integer",
        "email": "string",
        "display_name": "string",
        "notification_frequency": "string"
      }
    }
  }
  ```

### Create User
- **URL**: `/api/v0/users`
- **Method**: `POST`
- **URL Parameters**: None
- **Request Body**:
  ```json
  {
    "email": "string",
    "password": "string",
    "password_confirmation": "string",
    "display_name": "string",
    "notifications_token": "string"
  }
  ```
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "user",
      "attributes": {
        "id": "integer",
        "email": "string",
        "display_name": "string"
      }
    }
  }
  ```

### Update User
- **URL**: `/api/v0/users/{id}`
- **Method**: `PUT`
- **URL Parameters**: 
  - `id`: ID of the user
- **Request Body**:
  ```json
  {
    "email": "string",
    "password": "string",
    "password_confirmation": "string",
    "display_name": "string",
    "notification_frequency": "string",
    "last_tou_acceptance": "string",
    "notifications_token": "string"
  }
  ```
- **Response**: Status 204 No Content

### Delete User
- **URL**: `/api/v0/users/{id}`
- **Method**: `DELETE`
- **URL Parameters**: 
  - `id`: ID of the user
- **Request Body**: None
- **Response**: Status 204 No Content

### Get User Newsfeed
- **URL**: `/api/v0/users/{id}/newsfeed`
- **Method**: `GET`
- **URL Parameters**: 
  - `id`: ID of the user
- **Request Body**: None
- **Response**:
  ```json
  {
    "data": [
      {
        "id": "string",
        "type": "post",
        "attributes": {
          "id": "integer",
          "author_id": "integer",
          "caption": "string",
          "created_at": "timestamp",
          "updated_at": "timestamp",
          "circle_id": "integer",
          "author_display_name": "string",
          "circle_name": "string",
          "contents": {
            "data": [
              {
                "id": "string",
                "type": "content",
                "attributes": {
                  "video_url": "string",
                  "signed_image_url": "string"
                }
              }
            ]
          },
          "comments": {
            "data": [
              {
                "id": "string",
                "type": "comment",
                "attributes": {
                  "id": "integer",
                  "author_id": "integer",
                  "post_id": "integer",
                  "parent_comment_id": "integer",
                  "comment_text": "string",
                  "created_at": "timestamp",
                  "updated_at": "timestamp"
                }
              }
            ]
          }
        }
      }
    ]
  }
  ```

## Circle Endpoints

### Get All Circles
- **URL**: `/api/v0/circles`
- **Method**: `GET`
- **URL Parameters**: None
- **Request Body**: None
- **Response**:
  ```json
  {
    "data": [
      {
        "id": "string",
        "type": "circle",
        "attributes": {
          "id": "integer",
          "user_id": "integer",
          "name": "string",
          "description": "string"
        }
      }
    ]
  }
  ```

### Get Circle
- **URL**: `/api/v0/circles/{id}`
- **Method**: `GET`
- **URL Parameters**: 
  - `id`: ID of the circle
- **Request Body**: None
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "circle",
      "attributes": {
        "id": "integer",
        "user_id": "integer",
        "name": "string",
        "description": "string"
      }
    }
  }
  ```

### Get User Circles
- **URL**: `/api/v0/users/{user_id}/circles`
- **Method**: `GET`
- **URL Parameters**: 
  - `user_id`: ID of the user
- **Request Body**: None
- **Response**:
  ```json
  {
    "data": [
      {
        "id": "string",
        "type": "circle",
        "attributes": {
          "id": "integer",
          "user_id": "integer",
          "name": "string",
          "description": "string"
        }
      }
    ]
  }
  ```

### Create Circle
- **URL**: `/api/v0/users/{user_id}/circles`
- **Method**: `POST`
- **URL Parameters**: 
  - `user_id`: ID of the user
- **Request Body**:
  ```json
  {
    "user_id": "integer",
    "name": "string",
    "description": "string"
  }
  ```
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "circle",
      "attributes": {
        "id": "integer",
        "user_id": "integer",
        "name": "string",
        "description": "string"
      }
    }
  }
  ```

### Delete Circle
- **URL**: `/api/v0/users/{user_id}/circles/{id}`
- **Method**: `DELETE`
- **URL Parameters**: 
  - `user_id`: ID of the user
  - `id`: ID of the circle
- **Request Body**:
  ```json
  {
    "password": "string"
  }
  ```
- **Response**: Status 204 No Content

## Circle Member Endpoints

### Create Circle Member
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/circle_members`
- **Method**: `POST`
- **URL Parameters**: 
  - `user_id`: ID of the user (must be circle owner)
  - `circle_id`: ID of the circle
- **Request Body**:
  ```json
  {
    "new_member_id": "integer"
  }
  ```
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "circle_member",
      "attributes": {
        "id": "integer",
        "user_id": "integer",
        "circle_id": "integer"
      }
    }
  }
  ```

### Delete Circle Member
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/circle_members/{id}`
- **Method**: `DELETE`
- **URL Parameters**: 
  - `user_id`: ID of the user (must be circle owner)
  - `circle_id`: ID of the circle
  - `id`: ID of the circle member
- **Request Body**: None
- **Response**: Status 204 No Content

## Post Endpoints

### Get Circle Posts
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/posts`
- **Method**: `GET`
- **URL Parameters**: 
  - `user_id`: ID of the user
  - `circle_id`: ID of the circle
- **Request Body**: None
- **Response**:
  ```json
  {
    "data": [
      {
        "id": "string",
        "type": "post",
        "attributes": {
          "id": "integer",
          "author_id": "integer",
          "caption": "string",
          "created_at": "timestamp",
          "updated_at": "timestamp",
          "circle_id": "integer",
          "author_display_name": "string",
          "circle_name": "string",
          "contents": {
            "data": [
              {
                "id": "string",
                "type": "content",
                "attributes": {
                  "video_url": "string",
                  "signed_image_url": "string"
                }
              }
            ]
          },
          "comments": {
            "data": [
              {
                "id": "string",
                "type": "comment",
                "attributes": {
                  "id": "integer",
                  "author_id": "integer",
                  "post_id": "integer",
                  "parent_comment_id": "integer",
                  "comment_text": "string",
                  "created_at": "timestamp",
                  "updated_at": "timestamp"
                }
              }
            ]
          }
        }
      }
    ]
  }
  ```

### Create Post
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/posts`
- **Method**: `POST`
- **URL Parameters**: 
  - `user_id`: ID of the user
  - `circle_id`: ID of the circle
- **Request Body**:
  ```json
  {
    "post": {
      "caption": "string"
    },
    "contents": {
      "image": "string",
      "video": "string"
    }
  }
  ```
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "post",
      "attributes": {
        "id": "integer",
        "author_id": "integer",
        "caption": "string",
        "created_at": "timestamp",
        "updated_at": "timestamp",
        "circle_id": "integer",
        "author_display_name": "string",
        "circle_name": "string",
        "contents": {
          "data": [
            {
              "id": "string",
              "type": "content",
              "attributes": {
                "video_url": "string",
                "signed_image_url": "string"
              }
            }
          ]
        },
        "comments": {
          "data": []
        }
      }
    }
  }
  ```

### Update Post
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/posts/{id}`
- **Method**: `PUT`
- **URL Parameters**: 
  - `user_id`: ID of the user
  - `circle_id`: ID of the circle
  - `id`: ID of the post
- **Request Body**:
  ```json
  {
    "post": {
      "caption": "string"
    }
  }
  ```
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "post",
      "attributes": {
        "id": "integer",
        "author_id": "integer",
        "caption": "string",
        "created_at": "timestamp",
        "updated_at": "timestamp",
        "circle_id": "integer",
        "author_display_name": "string",
        "circle_name": "string",
        "contents": {
          "data": [
            {
              "id": "string",
              "type": "content",
              "attributes": {
                "video_url": "string",
                "signed_image_url": "string"
              }
            }
          ]
        },
        "comments": {
          "data": []
        }
      }
    }
  }
  ```

### Delete Post
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/posts/{id}`
- **Method**: `DELETE`
- **URL Parameters**: 
  - `user_id`: ID of the user
  - `circle_id`: ID of the circle
  - `id`: ID of the post
- **Request Body**: None
- **Response**: Status 204 No Content

## Comment Endpoints

### Get Post Comments
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/posts/{post_id}/comments`
- **Method**: `GET`
- **URL Parameters**: 
  - `user_id`: ID of the user
  - `circle_id`: ID of the circle
  - `post_id`: ID of the post
- **Request Body**: None
- **Response**:
  ```json
  {
    "data": [
      {
        "id": "string",
        "type": "comment",
        "attributes": {
          "id": "integer",
          "author_id": "integer",
          "post_id": "integer",
          "parent_comment_id": "integer",
          "comment_text": "string",
          "created_at": "timestamp",
          "updated_at": "timestamp"
        }
      }
    ]
  }
  ```

### Get Comment
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/posts/{post_id}/comments/{id}`
- **Method**: `GET`
- **URL Parameters**: 
  - `user_id`: ID of the user
  - `circle_id`: ID of the circle
  - `post_id`: ID of the post
  - `id`: ID of the comment
- **Request Body**: None
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "comment",
      "attributes": {
        "id": "integer",
        "author_id": "integer",
        "post_id": "integer",
        "parent_comment_id": "integer",
        "comment_text": "string",
        "created_at": "timestamp",
        "updated_at": "timestamp"
      }
    }
  }
  ```

### Create Comment
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/posts/{post_id}/comments`
- **Method**: `POST`
- **URL Parameters**: 
  - `user_id`: ID of the user
  - `circle_id`: ID of the circle
  - `post_id`: ID of the post
- **Request Body**:
  ```json
  {
    "comment_text": "string",
    "parent_comment_id": "integer"
  }
  ```
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "comment",
      "attributes": {
        "id": "integer",
        "author_id": "integer",
        "post_id": "integer",
        "parent_comment_id": "integer",
        "comment_text": "string",
        "created_at": "timestamp",
        "updated_at": "timestamp"
      }
    }
  }
  ```

### Update Comment
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/posts/{post_id}/comments/{id}`
- **Method**: `PUT`
- **URL Parameters**: 
  - `user_id`: ID of the user (must be comment author)
  - `circle_id`: ID of the circle
  - `post_id`: ID of the post
  - `id`: ID of the comment
- **Request Body**:
  ```json
  {
    "comment_text": "string"
  }
  ```
- **Response**:
  ```json
  {
    "data": {
      "id": "string",
      "type": "comment",
      "attributes": {
        "id": "integer",
        "author_id": "integer",
        "post_id": "integer",
        "parent_comment_id": "integer",
        "comment_text": "string",
        "created_at": "timestamp",
        "updated_at": "timestamp"
      }
    }
  }
  ```

### Delete Comment
- **URL**: `/api/v0/users/{user_id}/circles/{circle_id}/posts/{post_id}/comments/{id}`
- **Method**: `DELETE`
- **URL Parameters**: 
  - `user_id`: ID of the user (must be comment author or circle owner)
  - `circle_id`: ID of the circle
  - `post_id`: ID of the post
  - `id`: ID of the comment
- **Request Body**: None
- **Response**: Status 204 No Content 