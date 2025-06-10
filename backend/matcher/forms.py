from django import forms

class ResumeMatchForm(forms.Form):
    job_description = forms.CharField(widget=forms.Textarea(attrs={'rows': 5, 'cols': 40}))
    resume = forms.FileField()