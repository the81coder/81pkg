#!/bin/bash

OUTPUT=index.html

cat > $OUTPUT <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>81manorg APT Repository</title>
  <style>
    body {
      font-family: system-ui, sans-serif;
      max-width: 800px;
      margin: 2rem auto;
      padding: 1rem;
      background: #f9f9f9;
      color: #222;
    }
    h1 {
      color: #2c3e50;
    }
    ul {
      list-style: none;
      padding-left: 0;
    }
    li {
      margin: 0.5rem 0;
    }
    a {
      color: #1e90ff;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    code, pre {
      background: #eee;
      padding: 0.2rem 0.4rem;
      border-radius: 4px;
      font-size: 0.95rem;
    }
    hr {
      margin: 2rem 0;
    }
  </style>
</head>
<body>
  <h1>81manorg APT Repository</h1>
  <p>This is the public package index for the <strong>81pkg</strong> APT repo.</p>

  <h2>Available Packages</h2>
  <ul>
EOF

# List all .deb packages and create links
find pool -name "*.deb" | sort | while read -r deb; do
    name=$(basename "$deb")
    echo "    <li><a href=\"$deb\">$name</a></li>" >> "$OUTPUT"
done

cat >> $OUTPUT <<EOF
  </ul>

  <hr />

  <h3>APT Repo Info</h3>
  <pre>deb [trusted=yes] https://shreyashsarkaringithub4636.github.io/81pkg 81main main</pre>
</body>
</html>
EOF

echo "[✔] Index.html generated!"

