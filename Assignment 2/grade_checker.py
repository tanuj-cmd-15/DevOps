# grade_checker.py
def get_grade(score: float) -> str:
    if score >= 90:
        return "A"
    elif score >= 80:
        return "B"
    elif score >= 70:
        return "C"
    elif score >= 60:
        return "D"
    else:
        return "F"

def main():
    try:
        s = float(input("Enter score (0-100): ").strip())
        if s < 0 or s > 100:
            print("Please enter a score between 0 and 100.")
            return
    except ValueError:
        print("Invalid input — please enter a numeric score.")
        return

    grade = get_grade(s)
    print(f"Score: {s} -> Grade: {grade}")

if __name__ == "__main__":
    main()
