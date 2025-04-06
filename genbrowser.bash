#!/bin/bash

OUTPUT=index.html

cat > $OUTPUT <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>81manorg APT Repository</title>
</head>
<body>
    <h1>81manorg APT Repository</h1>
    <p>This is the public package index for the 81pkg APT repo.</p>
    <h2>Available Packages</h2>
    <ul>
EOF

find pool -name "*.deb" | while read -r deb; do
    echo "        <li><a href=\"$deb\">$(basename "$deb")</a></li>" >> $OUTPUT
done

cat >> $OUTPUT <<EOF
    </ul>
    <hr>
    <h3>APT Repo Info</h3>
    <pre>deb [trusted=yes] https://shreyashsarkaringithub4636.github.io/81pkg 81main main</pre>
</body>
</html>
EOF

echo "[✔] Generated $OUTPUT"
