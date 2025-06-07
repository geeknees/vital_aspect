# User Profile Editing

This feature lets signed-in users update their own email address and password.

## Usage
1. Log in and navigate to `/en/user/edit` or `/ja/user/edit`.
2. Modify the email address and/or password.
3. Submit the form to save changes.

## Implementation Details
- Routes are provided via `resource :user, only: %i[edit update]`.
- `UsersController` ensures the user is authenticated and updates the current user.
- The form lives in `app/views/users/edit.html.erb`.
