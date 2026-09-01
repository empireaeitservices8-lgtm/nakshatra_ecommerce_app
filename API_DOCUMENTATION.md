# Nakshatra Ecommerce API Documentation

This documentation details the REST API endpoints required by the **Nakshatra Gold & Diamonds** (Nakshatra Ecommerce) Flutter application. 

## General API Specifications
- **Base URL:** `http://100.52.86.195:8069/api/ecommerce`
- **Request Headers:**
  - `Content-Type: application/json`
  - `Authorization: Bearer <JWT_TOKEN>` (for protected endpoints)
- **Data Format:** JSON for all request and response bodies.

---

## 1. Authentication & User Profile

### Register User
* **Endpoint:** `POST /auth/register`
* **Description:** Register a new user account.
* **Request Body:**
  ```json
  {
    "name": "Sarah Williams",
    "phone": "+919876543210",
    "email": "sarah.williams@example.com",
    "password": "securepassword123"
  }
  ```
* **Response (201 Created):**
  ```json
  {
    "status": "success",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "usr_10029",
      "name": "Sarah Williams",
      "phone": "+919876543210",
      "email": "sarah.williams@example.com",
      "referral_code": "NAKSH-SHINE-77",
      "created_at": "2026-08-01T13:00:00Z"
    }
  }
  ```

### Log In
* **Endpoint:** `POST /auth/login`
* **Description:** Log in an existing user with phone and password.
* **Request Body:**
  ```json
  {
    "phone": "+919876543210",
    "password": "securepassword123"
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "usr_10029",
      "name": "Sarah Williams",
      "phone": "+919876543210",
      "email": "sarah.williams@example.com",
      "referral_code": "NAKSH-SHINE-77"
    }
  }
  ```

### Get Profile Details
* **Endpoint:** `GET /user/profile`
* **Description:** Fetch details of the logged-in user.
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "id": "usr_10029",
    "name": "Sarah Williams",
    "phone": "+919876543210",
    "email": "sarah.williams@example.com",
    "referral_code": "NAKSH-SHINE-77",
    "referral_balance": 500.0,
    "created_at": "2026-08-01T13:00:00Z"
  }
  ```

### Update Profile
* **Endpoint:** `PUT /user/profile`
* **Description:** Update user profile info.
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "name": "Sarah W. Williams",
    "email": "sarah.new@example.com"
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "user": {
      "id": "usr_10029",
      "name": "Sarah W. Williams",
      "phone": "+919876543210",
      "email": "sarah.new@example.com"
    }
  }
  ```

---

## 2. Catalog & Categories

### List Categories
* **Endpoint:** `GET /categories`
* **Description:** Retrieve list of jewelry categories.
* **Response (200 OK):**
  ```json
  [
    {
      "id": "cat_1",
      "name": "Rings",
      "image_url": "https://api.nakshatrajewelry.com/assets/categories/rings.png"
    },
    {
      "id": "cat_2",
      "name": "Necklaces",
      "image_url": "https://api.nakshatrajewelry.com/assets/categories/necklaces.png"
    },
    {
      "id": "cat_3",
      "name": "Earrings",
      "image_url": "https://api.nakshatrajewelry.com/assets/categories/earrings.png"
    },
    {
      "id": "cat_4",
      "name": "Bracelets",
      "image_url": "https://api.nakshatrajewelry.com/assets/categories/bracelets.png"
    }
  ]
  ```

### List Products
* **Endpoint:** `GET /products`
* **Description:** Retrieve paginated and filterable jewelry products.
* **Query Parameters:**
  - `category` (string): e.g. `Rings`
  - `gender` (string): `Womens` | `Gents` | `Unisex` | `Kids`
  - `search` (string): Text filter query
  - `page` (integer, default `1`)
  - `limit` (integer, default `10`)
  - `sort` (string): `price_asc` | `price_desc` | `popular`
* **Response (200 OK):**
  ```json
  {
    "products": [
      {
        "id": "prod_1",
        "title": "Bangles Set",
        "subtitle": "Gold",
        "price": "₹120.00",
        "imagePath": "assets/images/product1.png",
        "category": "Bracelets",
        "gender": "Womens"
      }
    ],
    "pagination": {
      "total": 11,
      "page": 1,
      "limit": 10,
      "pages": 2
    }
  }
  ```

### Product Detail
* **Endpoint:** `GET /products/{id}`
* **Description:** Retrieve detailed specifications for a single product.
* **Response (200 OK):**
  ```json
  {
    "id": "prod_3",
    "title": "Diamond Ring",
    "subtitle": "Diamond and Gold",
    "price": "₹369.00",
    "imagePath": "assets/images/product3.png",
    "category": "Rings",
    "gender": "Unisex",
    "description": "Exquisite 22K gold ring set with GIA certified VS1 round brilliant diamonds.",
    "weight_grams": 4.5,
    "purity": "22K Gold",
    "in_stock": true
  }
  ```

---

## 3. Shopping Cart

### Get Cart
* **Endpoint:** `GET /cart`
* **Description:** Fetch user's current shopping cart items.
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "items": [
      {
        "id": "cart_item_542",
        "product_id": "prod_1",
        "title": "Bangles Set",
        "price": "₹120.00",
        "imagePath": "assets/images/product1.png",
        "quantity": 1
      }
    ],
    "subtotal": 120.00,
    "shipping": 0.0,
    "total": 120.00
  }
  ```

### Add to Cart
* **Endpoint:** `POST /cart/items`
* **Description:** Add a product to the cart.
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "product_id": "prod_1",
    "quantity": 1
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Product added to cart",
    "cart_count": 1
  }
  ```

### Update Item Quantity
* **Endpoint:** `PUT /cart/items/{product_id}`
* **Description:** Update item quantity in the cart.
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "quantity": 2
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Cart quantity updated"
  }
  ```

### Remove Cart Item
* **Endpoint:** `DELETE /cart/items/{product_id}`
* **Description:** Remove item from the cart entirely.
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Item removed from cart"
  }
  ```

---

## 4. Wishlist

### Fetch Wishlist
* **Endpoint:** `GET /wishlist`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  [
    {
      "id": "prod_5",
      "title": "Gold Earrings",
      "subtitle": "Gold",
      "price": "₹89.00",
      "imagePath": "assets/images/earring.png"
    }
  ]
  ```

### Add to Wishlist
* **Endpoint:** `POST /wishlist`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "product_id": "prod_5"
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Product added to wishlist"
  }
  ```

### Remove from Wishlist
* **Endpoint:** `DELETE /wishlist/{product_id}`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Product removed from wishlist"
  }
  ```

---

## 5. Saved Addresses

### List Saved Addresses
* **Endpoint:** `GET /addresses`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  [
    {
      "id": "1",
      "label": "Home",
      "name": "Sarah Williams",
      "phone": "+91 98765 43210",
      "address": "Flat 402, Nakshathra Residency, MG Road, Kochi, Kerala - 682011"
    }
  ]
  ```

### Save New Address
* **Endpoint:** `POST /addresses`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "label": "Home",
    "name": "Sarah Williams",
    "phone": "+919876543210",
    "address": "Flat 402, Nakshathra Residency, MG Road, Kochi, Kerala - 682011"
  }
  ```
* **Response (201 Created):**
  ```json
  {
    "status": "success",
    "address": {
      "id": "1",
      "label": "Home",
      "name": "Sarah Williams",
      "phone": "+919876543210",
      "address": "Flat 402, Nakshathra Residency, MG Road, Kochi, Kerala - 682011"
    }
  }
  ```

### Delete Address
* **Endpoint:** `DELETE /addresses/{id}`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Address deleted successfully"
  }
  ```

---

## 6. Payment Methods & Saved Cards

### Fetch Saved Cards
* **Endpoint:** `GET /payment-methods`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  [
    {
      "id": "1",
      "number": "**** **** **** 6789",
      "expiry": "12/28",
      "holder": "Sarah Williams",
      "brand": "PLATINUM PRIME",
      "theme": "platinum"
    }
  ]
  ```

### Save Card
* **Endpoint:** `POST /payment-methods`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "number": "4321582090126789",
    "expiry_month": "12",
    "expiry_year": "28",
    "cvv": "123",
    "holder": "Sarah Williams",
    "brand": "PLATINUM PRIME",
    "theme": "platinum"
  }
  ```
* **Response (201 Created):**
  ```json
  {
    "status": "success",
    "card": {
      "id": "1",
      "number": "**** **** **** 6789",
      "expiry": "12/28",
      "holder": "Sarah Williams",
      "brand": "PLATINUM PRIME",
      "theme": "platinum"
    }
  }
  ```

---

## 7. Orders & Checkout

### Create Order (Checkout)
* **Endpoint:** `POST /orders`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "address_id": "1",
    "payment_method": "card",
    "card_id": "1",
    "coupon_code": "FREE100"
  }
  ```
* **Response (201 Created):**
  ```json
  {
    "status": "success",
    "orderId": "NX-9824A",
    "date": "August 01, 2026",
    "total": "₹120.00",
    "payment_status": "Paid",
    "order_status": "Processing"
  }
  ```

### List Orders (Order History)
* **Endpoint:** `GET /orders`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  [
    {
      "orderId": "NX-9824A",
      "date": "July 01, 2026",
      "status": "Processing",
      "items": [
        {
          "title": "Bangles Set",
          "price": "₹120.00",
          "imagePath": "assets/images/product1.png",
          "qty": 1
        }
      ],
      "total": "₹120.00"
    }
  ]
  ```

### Apply Coupon
* **Endpoint:** `POST /coupons/validate`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "code": "FREE100"
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "valid": true,
    "discount_amount": 100.0,
    "message": "Coupon FREE100 applied successfully"
  }
  ```

---

## 8. Product Reviews

### Fetch Product Reviews
* **Endpoint:** `GET /products/{product_id}/reviews`
* **Response (200 OK):**
  ```json
  [
    {
      "review_id": "rev_391",
      "user_name": "Rohan M.",
      "rating": 5,
      "comment": "Absolutely brilliant shine. Certified GIA card received.",
      "date": "2026-07-15T08:30:00Z"
    }
  ]
  ```

### Write Review
* **Endpoint:** `POST /products/{product_id}/reviews`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
  ```json
  {
    "rating": 5,
    "comment": "Beautifully crafted and premium gift boxes."
  }
  ```
* **Response (201 Created):**
  ```json
  {
    "status": "success",
    "message": "Review submitted successfully"
  }
  ```

---

## 9. Refer & Earn

### Referral Status & Info
* **Endpoint:** `GET /user/referral`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "referral_code": "NAKSH-SHINE-77",
    "referred_count": 3,
    "rewards_earned_inr": 1500.0,
    "history": [
      {
        "friend_name": "John Doe",
        "status": "Completed",
        "reward_amount": 500.0,
        "date": "2026-07-20"
      }
    ]
  }
  ```

---

## 10. Notifications

### Get Notifications
* **Endpoint:** `GET /notifications`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  [
    {
      "id": "notif_001",
      "title": "Order Shipped",
      "message": "Your Order NX-82937B has been shipped.",
      "time": "2 hours ago",
      "read": false
    }
  ]
  ```

### Mark Notification as Read
* **Endpoint:** `PUT /notifications/{id}/read`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Notification marked as read"
  }
  ```
