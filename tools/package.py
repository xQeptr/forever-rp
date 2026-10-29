#!/usr/bin/env python3
"""Package both clients from one ForeverRP source tree. No external dependencies."""
from pathlib import Path
import argparse,re,zipfile

P=argparse.ArgumentParser()
P.add_argument('--version',default='0.9.17',help='Version, optionally with a leading v')
args=P.parse_args()
version=args.version.removeprefix('v')
if not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+(?:[-.][A-Za-z0-9.]+)?',version):
    P.error('Version must look like 0.9.17 or 1.0.0-beta.1')
root=Path(__file__).resolve().parents[1]
source=root/'ForeverRP'
dist=root/'dist';dist.mkdir(exist_ok=True)
variants=(('Retail','120105','retail-beta'),('Forever','16001','forever-preview'))
for name,interface,suffix in variants:
    output=dist/f'ForeverRP-{name}-v{version}.zip'
    with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=8) as z:
        for f in sorted(source.rglob('*')):
            if not f.is_file(): continue
            rel=f.relative_to(root).as_posix()
            if f.name=='ForeverRP.toc':
                data=f.read_text()
                data=re.sub(r'(?m)^## Interface: .*$',f'## Interface: {interface}',data)
                data=re.sub(r'(?m)^## Version: .*$',f'## Version: {version}-{suffix}',data)
                z.writestr(rel,data)
            elif f.name=='Core.lua':
                data=f.read_text()
                data=re.sub(r"(?m)^A\.version = '[^']*'",f"A.version = '{version}-{suffix}'",data)
                z.writestr(rel,data)
            else:
                z.write(f,rel)
    with zipfile.ZipFile(output) as z:
        assert z.testzip() is None
        assert f'## Interface: {interface}'.encode() in z.read('ForeverRP/ForeverRP.toc')
        assert f"A.version = '{version}-{suffix}'".encode() in z.read('ForeverRP/Core.lua')
    print(output)
