# cs106b-autograder-runner
This script runs the Stanford CS106B autograder on a student's code.

Autograders are not included (for obvious reasons). This is NOT an autograder, but a script to run the autograder on students' code.

## Usage
Put `run_graders.sh` within the `assignment*` directory. The `assignment*` directory should contain subfolders with the student's SUNetID as the name. If you download assignments from Paperless, it will follow this convention. Each of these subfolders should contain the student's code, as well as the `*.pro` file. The script will run `qmake`, `make`, and the autograder on each student's code.

Run `chmod +x run_graders.sh` to make the script executable before running it.
Then, start the script with `./run_graders.sh`.

Once done, to quit all the running autograders, run `./run_graders.sh -q`. This will quit all apps with the name `Autograder` in the title.

```bash
chmod +x run_graders.sh
./run_graders.sh
```