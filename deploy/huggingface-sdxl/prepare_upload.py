"""Collect the four Space root files; do not copy Cooksy or private settings."""
from pathlib import Path
import shutil

source = Path(__file__).resolve().parent
project = source.parent.parent
target = project / 'build' / 'huggingface-sdxl'
target.mkdir(parents=True, exist_ok=True)
for name in ('app.py', 'requirements.txt', 'README.md'):
    shutil.copyfile(source / name, target / name)
shutil.copyfile(project / 'adapters' / 'vision_adapter.py', target / 'vision_adapter.py')
print(target)
