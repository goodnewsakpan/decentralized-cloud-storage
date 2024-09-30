# Decentralized Cloud Storage Smart Contract

This smart contract provides a decentralized cloud storage system allowing users to upload, update, transfer ownership, and manage file permissions. The contract ensures access control to prevent unauthorized access or modifications to files.

## Features

- Upload files with metadata such as name, size, and ownership.
- Update files for authorized users.
- Delete files for file owners.
- Transfer file ownership.
- Grant and revoke permissions to other users for file access.
- Retrieve file information and check file permissions.

---

## Constants

| Constant             | Value            | Description                                           |
|----------------------|------------------|-------------------------------------------------------|
| `contract-owner`      | `tx-sender`      | Owner of the contract (sender of the transaction).     |
| `err-owner-only`      | `(err u100)`     | Error: Only the owner of the file is authorized.       |
| `err-not-found`       | `(err u101)`     | Error: File not found.                                |
| `err-already-exists`  | `(err u102)`     | Error: File already exists.                           |
| `err-invalid-name`    | `(err u103)`     | Error: Invalid file name.                             |
| `err-invalid-size`    | `(err u104)`     | Error: Invalid file size.                             |
| `err-unauthorized`    | `(err u105)`     | Error: Unauthorized access attempt.                   |
| `err-invalid-recipient`| `(err u106)`    | Error: Invalid recipient (cannot be the owner).        |

---

## Data Variables

- **total-files**: A `uint` that keeps track of the total number of files uploaded.
  
### Maps:

- **files**: A mapping of file IDs to file metadata.
  - **file-id**: Unique identifier of the file.
  - **owner**: The owner of the file (principal).
  - **name**: The file's name (string-ascii 64).
  - **size**: The file size (uint).
  - **created-at**: The block height when the file was created.
  
- **file-permissions**: A map storing file permissions for users.
  - **file-id**: The file identifier.
  - **user**: The user granted permission.
  - **permission**: Boolean value indicating if the user has permission.

---

## Functions

### Private Functions

- **`file-exists(file-id uint)`**: Checks if a file with the given file ID exists.

- **`get-owner-file(file-id int, owner principal)`**: Verifies if the owner is associated with the given file ID.

- **`get-file-size-by-owner(file-id int)`**: Retrieves the size of the file based on ownership.

---

### Public Functions

- **`upload-file(name (string-ascii 64), size uint)`**: 
  Upload a new file with the specified name and size. Ensures the name and size are valid and assigns default permissions to the owner.

- **`update-file(file-id uint, new-name (string-ascii 64), new-size uint)`**: 
  Allows the owner to update the file's name and size. Only the owner can perform this operation.

- **`delete-file(file-id uint)`**: 
  Allows the owner to delete the file. Only the owner has the authorization to delete their file.

- **`transfer-file-ownership(file-id uint, new-owner principal)`**: 
  Transfers ownership of the file to another principal (user). Only the owner can transfer ownership.

- **`grant-permission(file-id uint, permission bool, recipient principal)`**: 
  Grants permission to a specified recipient to access the file. Only the owner can grant permissions.

- **`revoke-permission(file-id uint, user principal)`**: 
  Revokes previously granted permission for a specified user. Only the file owner can revoke permissions.

---

### Read-Only Functions

- **`get-total-files()`**: 
  Returns the total number of files stored in the system.

- **`check-permission(file-id uint, user principal)`**: 
  Checks if a specific user has permission to access the file.

- **`get-file-info(file-id uint)`**: 
  Retrieves metadata (owner, name, size, etc.) for the specified file ID.

---

## Usage and Authorization

- Only file owners can update, delete, or transfer file ownership.
- Permissions can be granted or revoked to other users, allowing them access to specific files.
- Permissions ensure secure access and management of files in a decentralized manner.

---

## Error Handling

The smart contract ensures robust error handling for unauthorized actions or invalid input parameters by returning specific error codes such as `err-not-found`, `err-unauthorized`, and `err-invalid-name`.

---

## Conclusion

This smart contract enables decentralized file storage with fine-grained access control using Clarity's language features. It allows for secure and transparent management of file metadata, ownership, and permissions, ensuring a scalable and decentralized approach to cloud storage.
