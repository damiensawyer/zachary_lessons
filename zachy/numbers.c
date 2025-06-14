#include <stdio.h>

int main() {
    float user_value;  // Use float to handle decimal input
    int invalid_number = 1;

    while (invalid_number) {
        printf("Please enter a number above 10: ");
        if (scanf("%f", &user_value) != 1) {
            // Clear the input buffer in case of invalid input
            while (getchar() != '\n');
            printf("Invalid input. Please enter a valid number.\n");
            continue;  // Skip the rest of the loop and prompt again
        }

        if (user_value > 10) {
            printf("Thanks, that works! %.2f is a great choice!\n", user_value);
            invalid_number = 0;  // Exit the loop
        } else {
            printf("That doesn't fit! Try again!\n");
        }
    }

    return 0;
}

