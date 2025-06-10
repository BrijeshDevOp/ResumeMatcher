# Resume Matcher (Flutter + Django)

![App Screenshot](https://drive.google.com/open?id=1P52Uxjo1XHYebzqdLp4bniXk2YZualOz&usp=drive_fs)

A smart full-stack application that helps job seekers optimize their resumes by matching them against job descriptions using AI-based semantic analysis.

## 🚀 Features

### 🔍 Resume Analysis
- Upload a resume (`.pdf` / `.docx`) and input a job description.
- Backend compares the semantic similarity between the resume and the job description using BERT embeddings.

### 📊 Result Visualization
- Displays a **similarity score** in percentage.
- Shows a **donut pie chart** with sections indicating:
  - Match score
  - Unmatched score
- Lists **missing keywords** from the job description not found in the resume.

### 📱 Flutter Frontend
- Upload job description and resume from a beautiful and intuitive interface.
- Result screen with:
  - Dynamic donut chart (rendered using Flutter)
  - Grid of missing keywords
  - Responsive UI for various screen sizes
- Snackbar notifications for user feedback using `awesome_snackbar_content`.

### 🧠 Django Backend
- Processes resume and JD text using:
  - **BERT-based embeddings** for semantic similarity
  - **Keyword extraction** from JD
- Responds with structured JSON containing:
  - Similarity score
  - Chart data
  - Missing keywords

