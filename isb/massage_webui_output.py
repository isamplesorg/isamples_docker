import os.path
import click


@click.command()
@click.option(
    "-u", "--url_to_replace", default=None, help="The URL to replace"
)
@click.option(
    "-r", "--replacement", default=None, help="The replacement URL"
)
@click.option(
    "-p", "--output_dir", default=None, help="The path to the JavaScript build output dir"
)
def main(url_to_replace, replacement, output_dir):
    print(f"Going to replace {url_to_replace} with {replacement} in JS files in {output_dir}")
    paths = os.listdir(output_dir)
    filtered_paths = [path for path in paths if path.endswith("js")]
    max_size = 0
    biggest_js_file = ""
    for filtered_path in filtered_paths:
        current_js_path = os.path.join(output_dir, filtered_path)
        current_size = os.path.getsize(current_js_path)
        if current_size > max_size:
            biggest_js_file = current_js_path
            max_size = current_size

    with open(biggest_js_file, "r") as js_source_file:
        js_source = js_source_file.read()
        js_source = js_source.replace(url_to_replace, replacement)
        with open(biggest_js_file, "w") as writable_file:
            writable_file.write(js_source)
    print(f"replaced file contents at {biggest_js_file}")
    
    
if __name__ == "__main__":
    main()    