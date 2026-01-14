# Contributing to Pan Tributario

First off, thank you for considering contributing to Pan Tributario! 🎉

It's people like you that make Pan Tributario such a great tool for accountants and businesses in Ecuador.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)
- [Questions?](#questions)

---

## 📜 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to [your-email@example.com].

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

---

## 🤝 How Can I Contribute?

### Types of Contributions

We welcome many types of contributions:

- 🐛 **Bug Reports** - Found something that doesn't work? Let us know!
- ✨ **Feature Requests** - Have an idea for a new feature?
- 📝 **Documentation** - Help improve our docs
- 🔧 **Code Contributions** - Fix bugs or implement features
- 🎨 **Design** - Improve UI/UX
- 🧪 **Testing** - Add or improve tests
- 🌍 **Translations** - Help translate the app

---

## 🚀 Getting Started

### Prerequisites

Before you begin, make sure you have:

- Node.js 18+ and npm
- Python 3.11+
- PostgreSQL 15+
- Git
- A GitHub account

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/tax_form_processor.git
   cd tax_form_processor
   ```

3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/CapBraco/tax_form_processor.git
   ```

4. **Create a branch** for your work:
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Local Development Setup

#### Backend Setup
```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt  # Development dependencies

# Setup environment
cp .env.example .env
# Edit .env with your local database credentials

# Run migrations
alembic upgrade head

# Start development server
uvicorn main:app --reload
```

#### Frontend Setup
```bash
cd frontend

# Install dependencies
npm install

# Setup environment
cp .env.example .env.local
# Edit .env.local with your local backend URL

# Start development server
npm run dev
```

#### Verify Setup
- Backend: http://localhost:8000/docs
- Frontend: http://localhost:3000

---

## 💻 Development Workflow

### 1. Create a Branch

Always create a new branch for your work:

```bash
# Feature branch
git checkout -b feature/add-form-101-support

# Bug fix branch
git checkout -b fix/upload-error-handling

# Documentation branch
git checkout -b docs/update-installation-guide
```

### 2. Make Your Changes

- Write clean, readable code
- Follow our [Coding Standards](#coding-standards)
- Add tests if applicable
- Update documentation if needed

### 3. Test Your Changes

#### Backend Testing
```bash
cd backend

# Run all tests
pytest

# Run with coverage
pytest --cov=app tests/

# Run specific test file
pytest tests/test_upload.py

# Run linting
flake8 .
black --check .
mypy .
```

#### Frontend Testing
```bash
cd frontend

# Run type check
npx tsc --noEmit

# Run linting
npm run lint

# Run formatter check
npx prettier --check .

# Build to check for errors
npm run build
```

### 4. Commit Your Changes

Follow our [Commit Message Guidelines](#commit-messages):

```bash
git add .
git commit -m "feat: add Form 101 support for income tax"
```

### 5. Keep Your Branch Updated

```bash
# Fetch latest changes from upstream
git fetch upstream

# Rebase your branch on upstream/main
git rebase upstream/main

# If conflicts occur, resolve them and continue
git rebase --continue
```

### 6. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 7. Create a Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill in the PR template
5. Submit!

---

## 📏 Coding Standards

### Backend (Python/FastAPI)

#### Style Guide
- Follow [PEP 8](https://pep8.org/)
- Use [Black](https://black.readthedocs.io/) for formatting
- Use [type hints](https://docs.python.org/3/library/typing.html)
- Maximum line length: 88 characters (Black default)

#### Code Structure
```python
"""Module docstring explaining purpose."""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.document import Document


async def get_documents(
    db: AsyncSession = Depends(get_db),
    skip: int = 0,
    limit: int = 100
) -> List[Document]:
    """
    Retrieve a list of documents.
    
    Args:
        db: Database session
        skip: Number of records to skip
        limit: Maximum number of records to return
        
    Returns:
        List of Document objects
        
    Raises:
        HTTPException: If database query fails
    """
    try:
        # Implementation here
        pass
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

#### Best Practices
- ✅ Use async/await for database operations
- ✅ Add docstrings to all functions
- ✅ Use type hints
- ✅ Handle exceptions properly
- ✅ Use environment variables for configuration
- ✅ Write unit tests for business logic
- ❌ Don't use `print()` - use logging instead
- ❌ Don't commit commented-out code
- ❌ Don't hardcode secrets or credentials

### Frontend (Next.js/TypeScript/React)

#### Style Guide
- Follow [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Use [Prettier](https://prettier.io/) for formatting
- Use TypeScript for type safety
- Use functional components with hooks

#### Component Structure
```typescript
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

/**
 * DocumentList component displays a list of processed documents
 * 
 * @param {Object} props - Component props
 * @param {Document[]} props.documents - Array of documents to display
 * @param {Function} props.onDelete - Callback when document is deleted
 * @returns {JSX.Element} Rendered component
 */
interface DocumentListProps {
  documents: Document[];
  onDelete: (id: string) => void;
}

export default function DocumentList({ documents, onDelete }: DocumentListProps) {
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  useEffect(() => {
    // Side effects here
  }, [documents]);

  const handleDelete = async (id: string) => {
    setLoading(true);
    try {
      await onDelete(id);
    } catch (error) {
      console.error('Delete failed:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="document-list">
      {/* Component JSX */}
    </div>
  );
}
```

#### Best Practices
- ✅ Use TypeScript interfaces for props
- ✅ Add JSDoc comments for complex functions
- ✅ Use meaningful variable names
- ✅ Extract reusable logic into custom hooks
- ✅ Use Next.js Image component for images
- ✅ Handle loading and error states
- ✅ Use Tailwind CSS classes (no inline styles)
- ❌ Don't use `console.log` in production
- ❌ Don't use `any` type unless absolutely necessary
- ❌ Don't create components over 300 lines

### File Naming Conventions

#### Backend
- Files: `snake_case.py`
- Classes: `PascalCase`
- Functions/variables: `snake_case`
- Constants: `UPPER_SNAKE_CASE`

#### Frontend
- Components: `PascalCase.tsx`
- Utilities: `camelCase.ts`
- Types: `PascalCase.ts` or `types.ts`
- Hooks: `use*.ts` (e.g., `useAuth.ts`)

---

## 📝 Commit Messages

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `build`: Build system changes

### Examples

```bash
# Simple feature
feat: add Form 101 support

# Bug fix with scope
fix(upload): handle PDF parsing errors correctly

# Breaking change
feat!: change API response format for documents

BREAKING CHANGE: The documents API now returns an object with 
metadata instead of a plain array.

# Multiple paragraphs
feat: add export to Excel functionality

This adds the ability to export documents to Excel format with 
proper formatting and formulas.

The export includes:
- Document metadata
- Extracted form data
- Yearly summaries

Closes #123
```

### Rules

- ✅ Use present tense ("add feature" not "added feature")
- ✅ Use imperative mood ("move cursor to..." not "moves cursor to...")
- ✅ First line should be 50 characters or less
- ✅ Separate subject from body with a blank line
- ✅ Wrap body at 72 characters
- ✅ Reference issues/PRs when applicable
- ❌ Don't end the subject line with a period
- ❌ Don't use generic messages like "fix bug" or "update code"

---

## 🔄 Pull Request Process

### Before Submitting

1. **Ensure your code follows our standards**
   - Run formatters (Black, Prettier)
   - Run linters (flake8, ESLint)
   - Run type checkers (mypy, TypeScript)

2. **Add tests if applicable**
   - Unit tests for business logic
   - Integration tests for API endpoints
   - Component tests for UI changes

3. **Update documentation**
   - Update README if needed
   - Add JSDoc/docstrings
   - Update API documentation if endpoints changed

4. **Test thoroughly**
   - Test on your local environment
   - Test edge cases
   - Test error scenarios

### PR Template

When creating a PR, please include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## How Has This Been Tested?
Describe your testing process

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added/updated
- [ ] All tests passing
- [ ] Dependent changes merged
```

### Review Process

1. **Automated checks** run on your PR
   - CI/CD pipeline
   - Code quality checks
   - Tests

2. **Code review** by maintainers
   - At least one approval required
   - Address review comments
   - Update PR as needed

3. **Merge** once approved
   - Maintainer will merge your PR
   - Your contribution is live! 🎉

### After Merge

- Delete your feature branch
- Pull latest changes to your local main
- Start working on your next contribution!

---

## 🐛 Reporting Bugs

### Before Submitting a Bug Report

1. **Check existing issues** - Your bug may already be reported
2. **Try the latest version** - Bug might be fixed
3. **Gather information**:
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Screenshots/videos
   - Environment details

### How to Submit a Bug Report

Use the GitHub issue template and include:

```markdown
**Describe the bug**
Clear description of what the bug is

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected behavior**
What you expected to happen

**Screenshots**
Add screenshots if applicable

**Environment:**
 - OS: [e.g., macOS 13.0]
 - Browser: [e.g., Chrome 120]
 - Version: [e.g., 1.0.0]

**Additional context**
Any other relevant information
```

---

## 💡 Suggesting Enhancements

### Before Submitting

1. **Check existing issues** - Feature may be planned
2. **Consider if it fits the project** - Is it aligned with goals?
3. **Think about implementation** - How would it work?

### How to Submit an Enhancement

```markdown
**Is your feature request related to a problem?**
Clear description of the problem

**Describe the solution you'd like**
Clear description of what you want to happen

**Describe alternatives you've considered**
Other solutions you've thought about

**Additional context**
Mockups, examples, etc.
```

---

## 📚 Additional Resources

### Documentation
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Next.js Documentation](https://nextjs.org/docs)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [React Documentation](https://react.dev/)

### Tools
- [Black](https://black.readthedocs.io/) - Python formatter
- [Prettier](https://prettier.io/) - JavaScript formatter
- [flake8](https://flake8.pycqa.org/) - Python linter
- [ESLint](https://eslint.org/) - JavaScript linter

### Community
- [GitHub Discussions](https://github.com/CapBraco/tax_form_processor/discussions)
- [Issues](https://github.com/CapBraco/tax_form_processor/issues)

---

## ❓ Questions?

If you have questions about contributing:

1. Check our [Documentation](https://github.com/CapBraco/tax_form_processor/wiki)
2. Ask in [GitHub Discussions](https://github.com/CapBraco/tax_form_processor/discussions)
3. Open an issue with the `question` label
4. Email: [your-email@example.com]

---

## 🙏 Recognition

Contributors are recognized in:
- README.md Contributors section
- Release notes
- Project documentation

Thank you for contributing to Pan Tributario! 🎉

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

<div align="center">

**Happy Contributing! 🚀**

Made with ❤️ by the Pan Tributario community

</div>
