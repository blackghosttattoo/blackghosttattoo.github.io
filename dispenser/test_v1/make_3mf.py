#!/usr/bin/env python3
"""OpenSCAD에서 내보낸 STL(출력 방향)들을 Bambu Studio에서 열 수 있는 3MF로 묶는다.
사용법: python3 make_3mf.py <stl폴더> <출력폴더>
각 부품은 별도 오브젝트로 들어가고, P2S 베드(256x256) 안에 배치된다."""
import re, sys, struct, zipfile, os

def read_stl(path):
    data = open(path, 'rb').read()
    tris = []
    if data[:5] == b'solid' and b'facet' in data[:300]:
        nums = re.findall(rb'vertex\s+(\S+)\s+(\S+)\s+(\S+)', data)
        v = [tuple(float(c) for c in n) for n in nums]
        tris = [v[i:i+3] for i in range(0, len(v), 3)]
    else:
        n = struct.unpack('<I', data[80:84])[0]
        for i in range(n):
            o = 84 + i*50 + 12
            tris.append([struct.unpack('<3f', data[o+j*12:o+j*12+12]) for j in range(3)])
    return tris

def mesh(tris):
    idx, verts, faces = {}, [], []
    for t in tris:
        f = []
        for p in t:
            k = (round(p[0], 4), round(p[1], 4), round(p[2], 4))
            if k not in idx:
                idx[k] = len(verts); verts.append(k)
            f.append(idx[k])
        if len(set(f)) == 3:
            faces.append(f)
    xs, ys, zs = zip(*verts)
    mn = (min(xs), min(ys), min(zs))
    verts = [(x-mn[0], y-mn[1], z-mn[2]) for x, y, z in verts]   # 원점 기준으로 이동, 바닥 z=0
    size = (max(xs)-mn[0], max(ys)-mn[1], max(zs)-mn[2])
    return verts, faces, size

def write_3mf(out, objects):
    """objects: [(이름, verts, faces, (x, y))]"""
    res, items = [], []
    for i, (name, verts, faces, pos) in enumerate(objects, start=1):
        v = ''.join(f'<vertex x="{x+pos[0]:.4f}" y="{y+pos[1]:.4f}" z="{z:.4f}"/>' for x, y, z in verts)
        t = ''.join(f'<triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in faces)
        res.append(f'<object id="{i}" name="{name}" type="model"><mesh><vertices>{v}</vertices><triangles>{t}</triangles></mesh></object>')
        items.append(f'<item objectid="{i}"/>')
    model = ('<?xml version="1.0" encoding="UTF-8"?>\n'
             '<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">'
             '<metadata name="Title">Cartridge dispenser test v1</metadata>'
             f'<resources>{"".join(res)}</resources><build>{"".join(items)}</build></model>')
    ct = ('<?xml version="1.0" encoding="UTF-8"?>\n'
          '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
          '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
          '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/></Types>')
    rels = ('<?xml version="1.0" encoding="UTF-8"?>\n'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Target="/3D/3dmodel.model" Id="rel0" '
            'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('[Content_Types].xml', ct)
        z.writestr('_rels/.rels', rels)
        z.writestr('3D/3dmodel.model', model)

def pack(parts, bed=256, gap=8):
    """간단한 줄 배치 (위에서 아래로 열 채우기)"""
    placed, x, y, colw = [], gap, gap, 0
    for name, verts, faces, size in parts:
        if y + size[1] > bed - gap:
            x += colw + gap; y = gap; colw = 0
        if x + size[0] > bed - gap:
            raise SystemExit(f'베드에 다 안 들어감: {name}')
        placed.append((name, verts, faces, (x, y)))
        y += size[1] + gap; colw = max(colw, size[0])
    return placed

if __name__ == '__main__':
    src, dst = sys.argv[1], sys.argv[2]
    plates = {
        'plate1_mechanism.3mf': [('lower_body', 'lower'), ('carrier_paddle', 'carrier'),
                                 ('anvil_block', 'anvil'), ('tongue', 'tongue')],
        'plate2_magazine.3mf':  [('upper_magazine', 'upper'), ('lid', 'lid'), ('pusher', 'pusher'),
                                 ('rod_1', 'rod'), ('rod_2', 'rod')],
    }
    for fname, plist in plates.items():
        parts = []
        for name, stl in plist:
            verts, faces, size = mesh(read_stl(os.path.join(src, stl + '.stl')))
            parts.append((name, verts, faces, size))
            print(f'  {name:16s} {size[0]:6.1f} x {size[1]:6.1f} x {size[2]:6.1f} mm, {len(faces)} tris')
        parts.sort(key=lambda p: -p[3][1])
        write_3mf(os.path.join(dst, fname), pack(parts))
        print('->', fname)
