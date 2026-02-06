# Code Reviewer

This skill guides the agent in conducting professional and thorough code reviews for both local development and remote Merge Requests.

## Workflow

### 1. Determine Review Target
*   **Remote MR**: If the user provides an MR number or URL (e.g., "Review MR !123"), target that remote MR.
*   **Local Changes**: If no specific MR is mentioned, or if the user asks to "review my changes", target the current local file system states (staged and unstaged changes).

### 2. Preparation

#### For Remote MRs:
1.  **Checkout**: Use the GitLab CLI to checkout the MR.
    ```bash
    glab mr checkout <MR_NUMBER>
    ```
2.  **Context**: Read the MR description and any existing comments to understand the goal and history.

#### For Local Changes:
1.  **Identify Changes**:
    *   Check status: `git status`
    *   Read diffs: `git diff` (working tree) and/or `git diff --staged` (staged).

### 3. In-Depth Analysis
Analyze the code changes based on the following pillars:

*   **Correctness**: Does the code achieve its stated purpose without bugs or logical errors?
*   **Maintainability**: Is the code clean, well-structured, and easy to understand and modify in the future? Consider factors like code clarity, modularity, and adherence to established design patterns.
*   **Readability**: Is the code well-commented (where necessary) and consistently formatted according to our project's coding style guidelines?
*   **Efficiency**: Are there any obvious performance bottlenecks or resource inefficiencies introduced by the changes?
*   **Security**: Are there any potential security vulnerabilities or insecure coding practices?
*   **Edge Cases and Error Handling**: Does the code appropriately handle edge cases and potential errors?
*   **Testability**: Is the new or modified code adequately covered by tests (even if preflight checks pass)? Suggest additional test cases that would improve coverage or robustness.

### 4. Provide Feedback

#### Structure
*   **Summary**: A high-level overview of the review.
*   **Findings**:
    *   **Critical**: Bugs, security issues, or breaking changes.
    *   **Improvements**: Suggestions for better code quality or performance.
    *   **Nitpicks**: Formatting or minor style issues (optional).
*   **Conclusion**: Clear recommendation (Approved / Request Changes).

#### Tone
*   Be constructive, professional, and friendly.
*   Explain *why* a change is requested.
*   For approvals, acknowledge the specific value of the contribution.

### 5. Cleanup (Remote MRs only)
*   After the review, ask the user if they want to switch back to the default branch (e.g., `main` or `master`).
