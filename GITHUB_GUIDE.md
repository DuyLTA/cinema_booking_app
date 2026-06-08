# GitHub Guide: Create New Repository and Push Code

## Creating a New GitHub Repository

### Step 1: Create Repository on GitHub

1. Go to [GitHub](https://github.com) and log in to your account
2. Click the **+** icon in the top-right corner
3. Select **New repository**
4. Fill in the repository details:
   - **Repository name**: e.g., `cinema_booking_app`
   - **Description**: A brief description of your project
   - **Public/Private**: Choose based on your preference
   - **Initialize with README**: Uncheck this (we'll add our own)
   - **Add .gitignore**: Select "Flutter" if available
   - **Choose a license**: Select if needed
5. Click **Create repository**

### Step 2: Initialize Git in Your Project

If your project doesn't have git initialized yet:

```bash
cd cinema_booking_app
git init
```

### Step 3: Add All Files to Git

```bash
git add .
```

### Step 4: Create Initial Commit

```bash
git commit -m "Initial commit"
```

### Step 5: Add Remote Repository

Copy the repository URL from GitHub (click the green "Code" button and copy the HTTPS URL)

```bash
git remote add origin https://github.com/your-username/cinema_booking_app.git
```

Replace `your-username` with your actual GitHub username.

### Step 6: Push to GitHub

```bash
git branch -M main
git push -u origin main
```

The `-u` flag sets the upstream branch, so future pushes can be done with just `git push`.

## Common Git Commands

### Check Status
```bash
git status
```

### View Changes
```bash
git diff
```

### Stage Specific Files
```bash
git add filename.dart
```

### Commit Changes
```bash
git commit -m "Your commit message"
```

### Push Changes
```bash
git push
```

### Pull Changes from GitHub
```bash
git pull
```

### Create a New Branch
```bash
git checkout -b feature/your-feature-name
```

### Switch Branches
```bash
git checkout branch-name
```

### Merge Branches
```bash
git checkout main
git merge feature/your-feature-name
```

### Delete Branch
```bash
git branch -d feature/your-feature-name
```

## Troubleshooting

### Error: "remote origin already exists"

If you get this error, remove the existing remote first:

```bash
git remote remove origin
git remote add origin https://github.com/your-username/cinema_booking_app.git
```

### Error: "failed to push some refs"

This usually means there are changes on GitHub that aren't in your local repository. Pull first:

```bash
git pull origin main --allow-unrelated-histories
```

Then push again:

```bash
git push origin main
```

### Error: "Permission denied"

Make sure you're authenticated with GitHub:
- For HTTPS: You'll need to use a personal access token (password authentication is deprecated)
- For SSH: Set up SSH keys on GitHub

## Using SSH Instead of HTTPS

If you prefer SSH:

1. Generate SSH key:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

2. Add SSH key to GitHub:
   - Copy the public key: `cat ~/.ssh/id_ed25519.pub`
   - Go to GitHub Settings → SSH and GPG keys → New SSH key
   - Paste the key

3. Use SSH URL:
```bash
git remote set-url origin git@github.com:your-username/cinema_booking_app.git
```

## Best Practices

1. **Write clear commit messages**: Use present tense and be descriptive
   - Good: "Add movie detail screen with trailer support"
   - Bad: "update stuff"

2. **Commit frequently**: Small, focused commits are easier to review and revert

3. **Use branches**: Create branches for features, bug fixes, etc.

4. **Pull before pushing**: Always pull latest changes before pushing to avoid conflicts

5. **Ignore sensitive files**: Make sure `.env` and other sensitive files are in `.gitignore`
