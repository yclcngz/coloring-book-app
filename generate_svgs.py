import os

def generate_svg(index, category):
    # A simple procedural SVG generation
    # We create overlapping shapes so kids can color different regions.
    
    svg_header = '<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">\n'
    svg_footer = '</svg>'
    
    shapes = []
    # Background
    shapes.append('<rect x="10" y="10" width="480" height="480" fill="none" stroke="black" stroke-width="4"/>')
    
    if category == 'animals':
        # Abstract animal-like (circles for head/body)
        r1 = 50 + (index * 5) % 100
        r2 = 30 + (index * 7) % 50
        shapes.append(f'<circle cx="250" cy="250" r="{r1}" fill="none" stroke="black" stroke-width="3"/>')
        shapes.append(f'<circle cx="250" cy="{250 - r1 - r2}" r="{r2}" fill="none" stroke="black" stroke-width="3"/>')
        # Ears
        shapes.append(f'<path d="M {250 - r2} {250 - r1 - r2} Q 200 100 250 {250 - r1 - r2 - r2}" fill="none" stroke="black" stroke-width="3"/>')
        shapes.append(f'<path d="M {250 + r2} {250 - r1 - r2} Q 300 100 250 {250 - r1 - r2 - r2}" fill="none" stroke="black" stroke-width="3"/>')

    elif category == 'flowers':
        # Abstract flower (petals around center)
        petals = 4 + (index % 6)
        shapes.append('<circle cx="250" cy="250" r="40" fill="none" stroke="black" stroke-width="3"/>')
        for p in range(petals):
            angle_str = f"rotate({p * (360/petals)} 250 250)"
            shapes.append(f'<ellipse cx="250" cy="150" rx="30" ry="60" fill="none" stroke="black" stroke-width="3" transform="{angle_str}"/>')
        shapes.append('<path d="M 250 290 L 250 480" fill="none" stroke="black" stroke-width="5"/>')
        shapes.append('<path d="M 250 380 Q 200 350 180 320" fill="none" stroke="black" stroke-width="3"/>')
        shapes.append('<path d="M 250 400 Q 300 370 320 340" fill="none" stroke="black" stroke-width="3"/>')

    elif category == 'items':
        # Abstract item (like a vase or cup)
        w = 100 + (index * 10) % 100
        h = 150 + (index * 15) % 100
        shapes.append(f'<rect x="{250 - w/2}" y="{250 - h/2}" width="{w}" height="{h}" rx="20" fill="none" stroke="black" stroke-width="3"/>')
        # Stripes for coloring
        for i in range(1, 5):
            y = 250 - h/2 + i * (h/5)
            shapes.append(f'<line x1="{250 - w/2}" y1="{y}" x2="{250 + w/2}" y2="{y}" stroke="black" stroke-width="3"/>')
        # Handle
        shapes.append(f'<path d="M {250 + w/2} {250 - h/4} A 40 40 0 0 1 {250 + w/2} {250 + h/4}" fill="none" stroke="black" stroke-width="3"/>')

    elif category == 'people':
        # Abstract person
        shapes.append('<circle cx="250" cy="150" r="50" fill="none" stroke="black" stroke-width="3"/>')
        # Eyes
        shapes.append('<circle cx="230" cy="140" r="5" fill="none" stroke="black" stroke-width="2"/>')
        shapes.append('<circle cx="270" cy="140" r="5" fill="none" stroke="black" stroke-width="2"/>')
        # Smile
        shapes.append('<path d="M 230 170 Q 250 190 270 170" fill="none" stroke="black" stroke-width="3"/>')
        # Body
        shapes.append('<path d="M 250 200 L 250 350" fill="none" stroke="black" stroke-width="3"/>')
        # Arms
        shapes.append('<path d="M 250 230 L 150 280 M 250 230 L 350 280" fill="none" stroke="black" stroke-width="3"/>')
        # Legs
        shapes.append('<path d="M 250 350 L 180 480 M 250 350 L 320 480" fill="none" stroke="black" stroke-width="3"/>')
        
    return svg_header + "\n".join(shapes) + "\n" + svg_footer

categories = ['animals', 'flowers', 'items', 'people']

for i in range(50):
    if i == 0:
        continue # skip 0 as we manually created it
    
    cat = categories[i % len(categories)]
    svg_content = generate_svg(i, cat)
    
    file_path = f"assets/images/{cat}/image_{i}.svg"
    
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, "w") as f:
        f.write(svg_content)
    
    print(f"Generated {file_path}")
