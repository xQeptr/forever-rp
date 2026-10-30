"""Lexical editorial triage, no third-party dependencies. Reads export_library.lua TSV."""
import collections
import itertools
import re
import sys

rows = [line.rstrip('\n').split('\t') for line in sys.stdin if line.strip()]
assert rows and all(len(row) == 7 for row in rows)
new = [r for r in rows if ':editorial-' in r[0]]
old = [r for r in rows if ':editorial-' not in r[0]]
def normalized(text):
    return ' '.join(re.findall(r'[a-z0-9]+', text.lower().replace('{item}', 'ITEM')))
def tokens(text):
    return set(normalized(text).split()) - {'item'}
exact = collections.defaultdict(list)
for row in rows:
    exact[normalized(row[6])].append(row)
pairs = []
for left, right in itertools.combinations(rows, 2):
    if left[3] != right[3]:
        continue
    a, b = tokens(left[6]), tokens(right[6])
    if min(len(a), len(b)) < 5:
        continue
    similarity = len(a & b) / len(a | b)
    if similarity >= .75:
        pairs.append((left, right, similarity))
new_pairs = [p for p in pairs if ':editorial-' in p[0][0] or ':editorial-' in p[1][0]]
print('# RP library variety audit\n')
print('Reproduce from the repository root: `lua tools/export_library.lua | python3 tools/audit_library.py > docs/rp-variety-report.md`.\n')
print(f'Historical entries: **{len(old)}**; additive entries: **{len(new)}**; total: **{len(rows)}**. Counts include dormant German historical entries.\n')
print('Lexical triage normalizes case/punctuation/whitespace and replaces the item placeholder. Near duplicates use token-set Jaccard >= 0.75, at least five distinct non-item tokens on both sides, within one language, including cross-category/context pairs. This is a review aid, not semantic proof; shared short syntax can score high.\n')
groups = [v for v in exact.values() if len(v) > 1]
print(f'Exact normalized duplicate groups: **{len(groups)}** ({sum(len(v)-1 for v in groups)} extra occurrences). Near-duplicate pairs: **{len(pairs)}**; pairs involving additions: **{len(new_pairs)}**.\n')
for index, title in [(1, 'Category'), (2, 'Source / race'), (3, 'Language'), (4, 'Channel'), (5, 'Context')]:
    print(f'## {title}\n\n| Value | Historical | Added | Total |\n|---|---:|---:|---:|')
    for key in sorted({r[index] for r in rows}):
        o=sum(r[index]==key for r in old); n=sum(r[index]==key for r in new)
        print(f'| {key} | {o} | {n} | {o+n} |')
    print()
print('## Full category / source / channel / context matrix\n\nEnglish only; each row is a selectable pool, not a claim of equal runtime weighting.\n')
print('| Category | Source | Channel | Context | Historical | Added | Total |\n|---|---|---|---|---:|---:|---:|')
keys=sorted({(r[1],r[2],r[4],r[5]) for r in rows if r[3]=='en'})
for key in keys:
    o=sum((r[1],r[2],r[4],r[5])==key and r[3]=='en' for r in old)
    n=sum((r[1],r[2],r[4],r[5])==key and r[3]=='en' for r in new)
    print('| '+' | '.join(key)+f' | {o} | {n} | {o+n} |')
print('\n## Addition similarity flags\n')
if not new_pairs:
    print('No addition reaches the stated near-duplicate threshold.')
for left,right,score in new_pairs:
    print(f'- {score:.3f}: `{left[0]}` / `{right[0]}`')
print('\n## Historical repeated-syntax examples (English)\n')
for group in sorted((g for g in groups if g[0][3]=='en'),key=lambda g:(-len(g),g[0][0]))[:8]:
    print(f'- {len(group)} occurrences: {group[0][6]}')
print('\n## Retained wording and byte-budget audit\n')
print('| Registry | English gendered-pronoun lines | English /me with embedded quotes | Maximum template bytes | Over 255 with 120-byte substitution |\n|---|---:|---:|---:|---:|')
for title,pool in [('Historical',old),('Added',new)]:
    gender=sum(r[3]=='en' and bool(re.search(r'\b(he|his|him|she|her|hers)\b',r[6],re.I)) for r in pool)
    quotes=sum(r[3]=='en' and r[4]=='me' and '"' in r[6] for r in pool)
    maximum=max(len(r[6].encode()) for r in pool)
    over=sum(len(r[6].replace('{item}','x'*120).encode())>255 for r in pool)
    print(f'| {title} | {gender} | {quotes} | {maximum} | {over} |')
print('\nEmbedded dialogue in historical /me is stylistically mixed, not necessarily invalid chat syntax. New actions use narration only. The 120-byte substitution is a stated test budget, not a guaranteed upper bound for every real hyperlink; send-time validation remains mandatory.')
print('\nSemantic review and retained historical issues: [writing guide](rp-writing-guide.md). No historical line was removed to improve these metrics.')
