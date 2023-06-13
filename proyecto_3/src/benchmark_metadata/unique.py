def remove_duplicates(input_file, output_file):
    lines_seen = set()
    with open(input_file, "r") as file_in, open(output_file, "w") as file_out:
        for line in file_in:
            line = line.strip()
            if line not in lines_seen:
                file_out.write(line + "\n")
                lines_seen.add(line)

input_file_path = "execution_stripped.txt.old"
output_file_path = "execution_stripped.txt"
remove_duplicates(input_file_path, output_file_path)