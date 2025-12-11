def main():
    filename = "output.txt"
    content = """Hello!
This is a sample file created by write_file.py.
You can replace this with any content you want.
"""

    # Write content
    with open(filename, "w") as f:
        f.write(content)

    # Read content
    with open(filename, "r") as f:
        print("File content:")
        print(f.read())

if __name__ == "__main__":
    main()
