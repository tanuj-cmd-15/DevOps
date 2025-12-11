import json
import os

DATA_FILE = "student_grades.json"

def load_grades():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    return {}

def save_grades(grades):
    with open(DATA_FILE, "w") as f:
        json.dump(grades, f, indent=2)
    print(f"Saved grades to {DATA_FILE}")

def print_grades(grades):
    if not grades:
        print("No student grades to show.")
        return
    print("Student Grades:")
    for name, grade in grades.items():
        print(f" - {name}: {grade}")

def main():
    grades = load_grades()
    while True:
        print("\nMenu: [1] Add  [2] Update  [3] Print All  [4] Save  [5] Exit")
        choice = input("Choose option: ").strip()
        if choice == "1":
            name = input("Student name: ").strip()
            if not name:
                print("Name cannot be empty.")
                continue
            grade = input("Grade (A/B/C/D/F): ").strip().upper()
            if grade not in {"A","B","C","D","F"}:
                print("Invalid grade. Use A, B, C, D or F.")
                continue
            if name in grades:
                print(f"{name} already exists with grade {grades[name]}. Use Update to change.")
            else:
                grades[name] = grade
                print(f"Added {name}: {grade}")
        elif choice == "2":
            name = input("Student name to update: ").strip()
            if name not in grades:
                print(f"{name} not found.")
                continue
            grade = input("New grade (A/B/C/D/F): ").strip().upper()
            if grade not in {"A","B","C","D","F"}:
                print("Invalid grade.")
                continue
            grades[name] = grade
            print(f"Updated {name} -> {grade}")
        elif choice == "3":
            print_grades(grades)
        elif choice == "4":
            save_grades(grades)
        elif choice == "5":
            print("Exiting. (Tip: choose Save before exit to persist changes.)")
            break
        else:
            print("Invalid option. Choose 1-5.")

if __name__ == "__main__":
    main()
