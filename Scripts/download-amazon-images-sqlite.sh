#!/usr/bin/env sh
# Alexis Megas.

if [ -z "$1" ]; then
    echo "Database?"
    exit 1
fi

if [ ! -x "$(which base64)" ]; then
    echo "Missing base64."
    exit 1
fi

if [ ! -x "$(which sqlite3)" ]; then
    echo "Missing sqlite3."
    exit 1
fi

if [ ! -x "$(which wget)" ]; then
    echo "Missing wget."
    exit 1
fi

rm -f "$0.output"

for id in \
    $(sqlite3 $1 "SELECT TRIM(id, '-') FROM book WHERE id IS NOT NULL"); do
    echo -n "Fetching $id... "
    wget --output-document "$id.jpg" \
	 --quiet \
	 "https://m.media-amazon.com/images/P/$id.01._SCMZZZZZZZ_.jpg"

    if [ $? -eq 0 ]; then
	echo "Downloaded."
	echo "UPDATE book SET front_cover = " \
	     "'$(cat "$id.jpg" | base64)'" \
	     "WHERE TRIM(id, '-') = " \
	     "'$id';" >> "$0.output"
    else
	echo "Image not found."
    fi

    rm -f "$id.jpg"
done

sqlite3 "$1" < "$0.output" 2>/dev/null
rm -f "$0.output"