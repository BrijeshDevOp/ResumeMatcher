import os
import re
import nltk
import torch
import pandas as pd
import docx2txt
import PyPDF2
import matplotlib.pyplot as plt
from collections import Counter
from nltk.corpus import stopwords
from django.conf import settings
from sentence_transformers import SentenceTransformer, util
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

# Use non-interactive backend for matplotlib
plt.switch_backend('Agg')

# Initialize BERT model
bert_model = SentenceTransformer('all-MiniLM-L6-v2')

# Download stopwords
nltk.download('stopwords')
STOPWORDS = set(stopwords.words('english'))

# Load dataset from data folder
DATASET_PATH = os.path.join(settings.BASE_DIR, 'data', 'job_skills_with_weights.csv')
try:
    df = pd.read_csv(DATASET_PATH)
except FileNotFoundError:
    raise FileNotFoundError(f"Dataset not found at {DATASET_PATH}")

# Create job skills dictionary
job_skills = {}
for _, row in df.iterrows():
    job_role = row['Job Role']
    skill = row['Skill']
    weight = row['Weight']
    if job_role not in job_skills:
        job_skills[job_role] = []
    job_skills[job_role].append((skill, weight))

# Precompute keyword embeddings
keyword_phrases = [skill for sublist in job_skills.values() for skill, _ in sublist]
keyword_embeddings = bert_model.encode(keyword_phrases, convert_to_tensor=True)


# Reused functions (unchanged from previous response)
def extract_text(file_path):
    """Extract text from PDF, DOCX, or text files."""
    text = ""
    try:
        if file_path.endswith('.pdf'):
            with open(file_path, 'rb') as f:
                reader = PyPDF2.PdfReader(f)
                for page in reader.pages:
                    page_text = page.extract_text()
                    if page_text:
                        text += page_text + "\n"
        elif file_path.endswith('.docx'):
            text = docx2txt.process(file_path)
        elif file_path.endswith('.txt'):
            with open(file_path, 'r', encoding='utf-8') as f:
                text = f.read()
        else:
            raise ValueError("Unsupported file format.")

        if not text.strip():
            raise ValueError("No text extracted from file.")
    except Exception as e:
        return f"ERROR: Could not extract text - {str(e)}"
    return text


def extract_keywords_simple(text):
    """Extract keywords using regex and stopwords filtering."""
    words = re.findall(r'\b[a-zA-Z]{3,}\b', text.lower())
    filtered_words = [word for word in words if word not in STOPWORDS]
    word_counts = Counter(filtered_words)
    return sorted(word_counts, key=word_counts.get, reverse=True)[:30]


def extract_keywords_advanced(text, threshold=0.5):
    """Extract keywords using BERT similarity with dataset phrases."""
    words_or_phrases = text.split()  # Basic tokenization
    text_embeddings = bert_model.encode(words_or_phrases, convert_to_tensor=True)
    cos_sim = util.pytorch_cos_sim(text_embeddings, keyword_embeddings)
    top_k = torch.topk(cos_sim, k=1, dim=1)

    matched_keywords = set()
    for i, index in enumerate(top_k.indices):
        matched_keyword = keyword_phrases[index.item()]
        similarity_score = cos_sim[i][index].item()
        if similarity_score >= threshold:
            matched_keywords.add(matched_keyword.lower())
    return matched_keywords


def get_missing_keywords(resume_keywords, jd_keywords, job_skills, threshold=0.5):
    """Identify missing keywords with prioritization."""
    missing_keywords = []
    for category, skills in job_skills.items():
        for skill, weight in skills:
            if skill.lower() in jd_keywords and skill.lower() not in resume_keywords:
                missing_keywords.append((skill.lower(), weight, category))

    priority_map = []
    for keyword, weight, category in missing_keywords:
        try:
            keyword_position = [s[0].lower() for s in job_skills[category]].index(keyword)
        except ValueError:
            keyword_position = len(job_skills[category])
        final_priority = weight * (len(job_skills[category]) - keyword_position)
        priority_map.append((keyword, final_priority))

    priority_map.sort(key=lambda x: x[1], reverse=True)
    return [keyword for keyword, _ in priority_map[:15]]


def generate_donut_chart(similarity_score):
    """Generate a donut chart for the similarity score."""
    sizes = [similarity_score, 100 - similarity_score]
    colors = ["#66BB6A", "#EF5350"]
    labels = ["Matched", "Unmatched"]

    fig, ax = plt.subplots(figsize=(6, 6), subplot_kw=dict(aspect="equal"))
    wedges, _ = ax.pie(
        sizes,
        colors=colors,
        startangle=90,
        wedgeprops=dict(width=0.4, edgecolor='white', linewidth=2, antialiased=True),
    )

    centre_circle = plt.Circle((0, 0), 0.6, fc='white', antialiased=True)
    ax.add_artist(centre_circle)

    ax.text(
        0, 0,
        f"{similarity_score:.1f}%",
        horizontalalignment='center',
        verticalalignment='center',
        fontsize=26,
        fontweight='bold',
        color='#3F51B5',
        family='DejaVu Sans'
    )

    plt.title("Resume Match Score", fontsize=16, fontweight='bold', pad=20)
    plt.axis('off')
    fig.legend(
        wedges,
        labels,
        loc='lower center',
        bbox_to_anchor=(0.5, -0.05),
        ncol=2,
        frameon=False,
        fontsize=15
    )

    plt.tight_layout()
    chart_path = os.path.join(settings.MEDIA_ROOT, 'chart.png')
    plt.savefig(chart_path, format='png', dpi=300, bbox_inches='tight')
    plt.close()
    return chart_path


@csrf_exempt
def match_resume(request):
    """API to match resume with job description and return keyword analysis."""
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid request method. Use POST.'}, status=405)

    # Validate inputs
    job_description = request.POST.get('job_description', '').strip()
    if not job_description:
        return JsonResponse({'error': 'Job description is missing.'}, status=400)

    resume_file = request.FILES.get('resume')
    if not resume_file:
        return JsonResponse({'error': 'Resume file is missing.'}, status=400)

    # Save resume file
    os.makedirs(settings.MEDIA_ROOT, exist_ok=True)
    resume_path = os.path.join(settings.MEDIA_ROOT, resume_file.name)
    try:
        with open(resume_path, 'wb+') as destination:
            for chunk in resume_file.chunks():
                destination.write(chunk)
    except Exception as e:
        return JsonResponse({'error': f'Error saving resume: {str(e)}'}, status=500)

    # Extract text
    resume_text = extract_text(resume_path)
    if "ERROR" in resume_text:
        return JsonResponse({'error': resume_text}, status=400)

    try:
        # Compute similarity
        jd_embedding = bert_model.encode(job_description, convert_to_tensor=True)
        resume_embedding = bert_model.encode(resume_text, convert_to_tensor=True)
        similarity_score = util.pytorch_cos_sim(jd_embedding, resume_embedding).item() * 100

        # Extract keywords
        jd_keywords = extract_keywords_advanced(job_description)
        resume_keywords = extract_keywords_advanced(resume_text)

        # Compute keyword sets
        matched = jd_keywords.intersection(resume_keywords)
        missing = jd_keywords - resume_keywords
        extra = resume_keywords - jd_keywords
        unrecognized = set()  # Placeholder (no unrecognized keywords in this implementation)

        # Calculate pie chart percentages
        total_keywords = len(jd_keywords.union(resume_keywords))
        if total_keywords > 0:
            matched_percent = (len(matched) / total_keywords) * 100
            missing_percent = (len(missing) / total_keywords) * 100
            extra_percent = (len(extra) / total_keywords) * 100
            unrecognized_percent = (len(unrecognized) / total_keywords) * 100
        else:
            matched_percent = missing_percent = extra_percent = unrecognized_percent = 0.0

        # Generate chart
        chart_path = generate_donut_chart(similarity_score)

        # Prepare response
        response = {
            # 'resume_keywords': list(resume_keywords),
            # 'jd_keywords': list(jd_keywords),
            # 'matched': list(matched),
            'missing': list(missing),
            # 'extra': list(extra),
            # 'unrecognized': list(unrecognized),
            'pie_chart_percentages': {
                'matched_percent': round(matched_percent, 2),
                'missing_percent': round(missing_percent, 2),
                'extra_percent': round(extra_percent, 2),
                'unrecognized_percent': round(unrecognized_percent, 2)
            },
            'similarity_score': round(similarity_score, 2),
            # 'chart_path': '/media/chart.png'
        }
    except Exception as e:
        return JsonResponse({'error': f'Processing error: {str(e)}'}, status=500)
    finally:
        # Clean up resume file
        if os.path.exists(resume_path):
            os.remove(resume_path)

    return JsonResponse(response)