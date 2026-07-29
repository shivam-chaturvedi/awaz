import re

file_path = r'c:\Users\fortn\Desktop\awaz\lib\services\vocabulary_initializer.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

def replacer(match):
    labels_match = re.search(r"labels:\s*\{'en':\s*'([^']+)'\}", match.group(0))
    if labels_match:
        label = labels_match.group(1)
        if 'imagePath:' not in match.group(0):
            insert_str = f"\n        imagePath: 'assets/images/{label.replace(' ', '_')}.jpg',"
            return match.group(0).replace('id: _uuid.v4(),', 'id: _uuid.v4(),' + insert_str)
    return match.group(0)

new_content = re.sub(r'VocabularyItem\([^)]+\)', replacer, content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)
