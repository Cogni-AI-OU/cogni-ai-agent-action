% CONSTRAINTS.mzn
% Formal mapping of agent roles to required skills vs. available paths.
% Used to verify if action.yml provides strict principle of least privilege.
% Also defines runtime bounds, budgets, and logical enforcing functions.

% --- Parameters (Budgets and Limits) ---
% Derived from Global_Budget_Protocol (GBP) and Loop_Arrest_Protocol (LAP) in FLOWS.mmd
int: MAX_STEPS = 20;               % Gated by Global_Budget_Protocol (GBP1)
int: MAX_TOOL_CALLS = 100;         % Gated by Global_Budget_Protocol (GBP2)
int: MAX_TOKEN_BUDGET = 50000;     % Gated by Global_Budget_Protocol (GBP3)
int: MAX_TIME_TTL = 3600;          % Gated by Global_Budget_Protocol (GBP4) - seconds
int: MAX_REPETITION = 3;           % Gated by Loop_Arrest_Protocol (LAP2)
int: MAX_PARTITION_STEPS = 8;      % Gated by State-Compression Protocol (CP1)
int: HARD_CHECKPOINT_THRESHOLD = 5; % Gated by State-Compression Protocol (CP5)

% --- Sets & Enums ---
enum AGENTS = {
    ARCHITECT, AUDITOR, BRAIN_OPS, CODE_REVIEWER, CONTEXT7_OPS, DEVOPS,
    DOCS_EDITOR, ELITE, FACT_OPS, GITHUB_OPS, KEEPER, PLAN_REVIEWER,
    PYTHON_DEV, SECURITY_AUDITOR, TESTER, WEAVER, MANAGER
};

enum SKILLS = {
    SKILL_AGENT_LOG_ANALYSIS, SKILL_ANSIBLE, SKILL_CAT, SKILL_CODE_TOUR,
    SKILL_CONTEXT_AWARE_OPS, SKILL_DOCS_REVIEW, SKILL_FACT_WRITER, SKILL_GH,
    SKILL_GH_API, SKILL_GH_ISSUE, SKILL_GH_MODELS, SKILL_GH_PR, SKILL_GH_RUN,
    SKILL_GIT, SKILL_GIT_EXPERT, SKILL_GITHUB, SKILL_GITHUB_ACTIONS,
    SKILL_GITHUB_ISSUE, SKILL_GITHUB_PR, SKILL_GITHUB_PR_REVIEW,
    SKILL_GITHUB_SCRIPT, SKILL_MERMAID_BETA, SKILL_MINIZINC,
    SKILL_MOLECULE, SKILL_PDF, SKILL_PRE_COMMIT, SKILL_ROBUST_COMMANDS,
    SKILL_SHELL, SKILL_SKILL_WRITER, SKILL_SUBAGENT_TASK, SKILL_TDD, SKILL_VIM_EX
};

enum TOOLS = {
    BASH, CONTEXT7_QUERY_DOCS, CONTEXT7_RESOLVE_LIBRARY_ID, EDIT, GLOB, GREP,
    READ, SKILL, TASK, TODOWRITE, WEBFETCH, WEBSEARCH, WRITE
};

enum BASH_CMDS = {
    CMD_ANSIBLE, CMD_MOLECULE, CMD_TERRAFORM, CMD_TERRAGRUNT, CMD_PULUMI,
    CMD_NPM_TEST, CMD_PYTEST, CMD_GH, CMD_GIT, CMD_PYTHON, CMD_DOCKER, CMD_JINJA2
};

% --- Model parameters (derived from action.yml) ---
% Flaw: skills.paths = ["${{ runner.temp }}/.skills"] gives ALL agents access to ALL discovered skills.
bool: global_skills_path_provisioning = true;

% --- Requirements ---
array[AGENTS] of set of SKILLS: required_skills = [
    {SKILL_GH, SKILL_GH_ISSUE, SKILL_GH_PR, SKILL_GITHUB_ISSUE, SKILL_GITHUB_PR, SKILL_GIT, SKILL_MINIZINC, SKILL_SHELL, SKILL_SUBAGENT_TASK}, % ARCHITECT
    {SKILL_AGENT_LOG_ANALYSIS, SKILL_GH, SKILL_GIT, SKILL_SHELL}, % AUDITOR
    {SKILL_GH, SKILL_GH_API, SKILL_GH_ISSUE, SKILL_GH_MODELS, SKILL_GH_PR, SKILL_GH_RUN, SKILL_GIT, SKILL_GITHUB, SKILL_GITHUB_ACTIONS, SKILL_GITHUB_ISSUE, SKILL_GITHUB_PR, SKILL_GITHUB_SCRIPT, SKILL_MINIZINC, SKILL_MERMAID_BETA, SKILL_SUBAGENT_TASK}, % BRAIN_OPS
    {SKILL_GH, SKILL_GH_PR, SKILL_GITHUB, SKILL_GITHUB_PR, SKILL_GITHUB_PR_REVIEW, SKILL_GIT, SKILL_MERMAID_BETA}, % CODE_REVIEWER
    {SKILL_GH, SKILL_GIT, SKILL_CONTEXT_AWARE_OPS, SKILL_MERMAID_BETA}, % CONTEXT7_OPS
    {SKILL_GH, SKILL_GH_API, SKILL_GIT, SKILL_MINIZINC, SKILL_ANSIBLE, SKILL_MOLECULE, SKILL_SHELL, SKILL_MERMAID_BETA, SKILL_SUBAGENT_TASK}, % DEVOPS
    {SKILL_GH, SKILL_GIT, SKILL_DOCS_REVIEW, SKILL_MERMAID_BETA}, % DOCS_EDITOR
    {SKILL_GH, SKILL_GIT, SKILL_MINIZINC, SKILL_SHELL, SKILL_SUBAGENT_TASK}, % ELITE
    {SKILL_GH, SKILL_GIT, SKILL_FACT_WRITER, SKILL_MERMAID_BETA}, % FACT_OPS
    {SKILL_GH, SKILL_GH_API, SKILL_GH_ISSUE, SKILL_GH_PR, SKILL_GITHUB, SKILL_GITHUB_ISSUE, SKILL_GITHUB_PR, SKILL_GIT, SKILL_MERMAID_BETA, SKILL_SUBAGENT_TASK}, % GITHUB_OPS
    {SKILL_GH, SKILL_GIT, SKILL_FACT_WRITER, SKILL_MERMAID_BETA}, % KEEPER
    {SKILL_GH, SKILL_GIT, SKILL_MERMAID_BETA}, % PLAN_REVIEWER
    {SKILL_GH, SKILL_GIT, SKILL_SHELL, SKILL_MERMAID_BETA, SKILL_TDD, SKILL_SUBAGENT_TASK}, % PYTHON_DEV
    {SKILL_GH, SKILL_GIT, SKILL_SHELL, SKILL_MERMAID_BETA}, % SECURITY_AUDITOR
    {SKILL_GH, SKILL_GIT, SKILL_MOLECULE, SKILL_SHELL, SKILL_MERMAID_BETA, SKILL_TDD, SKILL_SUBAGENT_TASK}, % TESTER
    {SKILL_GH, SKILL_GIT, SKILL_MERMAID_BETA}, % WEAVER
    {SKILL_GH, SKILL_GIT, SKILL_SUBAGENT_TASK} % MANAGER
];

array[AGENTS] of set of TOOLS: required_tools = [
    {BASH, EDIT, GLOB, GREP, READ, SKILL, TASK, TODOWRITE, WEBFETCH, WEBSEARCH, WRITE}, % ARCHITECT
    {BASH, GLOB, READ, SKILL, TASK, TODOWRITE}, % AUDITOR
    {BASH, GLOB, READ, SKILL, TASK, TODOWRITE, WEBFETCH, WEBSEARCH}, % BRAIN_OPS
    {GLOB, GREP, READ}, % CODE_REVIEWER
    {GLOB, READ, SKILL, TASK, TODOWRITE, CONTEXT7_QUERY_DOCS, CONTEXT7_RESOLVE_LIBRARY_ID}, % CONTEXT7_OPS
    {BASH, GLOB, READ, SKILL, TASK, TODOWRITE, WRITE}, % DEVOPS
    {EDIT, GLOB, READ, SKILL, TASK, TODOWRITE, WRITE}, % DOCS_EDITOR
    {BASH, EDIT, GLOB, GREP, READ, SKILL, TASK, TODOWRITE, WEBFETCH, WEBSEARCH, WRITE}, % ELITE
    {GLOB, READ, SKILL, TODOWRITE, WRITE}, % FACT_OPS
    {BASH, GLOB, READ, SKILL, TASK, TODOWRITE}, % GITHUB_OPS
    {GLOB, READ, SKILL, TODOWRITE, WRITE}, % KEEPER
    {GLOB, READ}, % PLAN_REVIEWER
    {BASH, EDIT, GLOB, GREP, READ, SKILL, TASK, TODOWRITE, WRITE}, % PYTHON_DEV
    {GLOB, READ, SKILL, TASK, TODOWRITE}, % SECURITY_AUDITOR
    {BASH, GLOB, READ, SKILL, TASK, TODOWRITE}, % TESTER
    {GLOB, READ, SKILL, TASK, TODOWRITE}, % WEAVER
    {GLOB, READ, SKILL, TASK, TODOWRITE} % MANAGER
];

array[AGENTS] of set of BASH_CMDS: required_bash = [
    {CMD_GH, CMD_GIT}, % ARCHITECT
    {CMD_GH}, % AUDITOR
    {CMD_GH}, % BRAIN_OPS
    {}, % CODE_REVIEWER
    {}, % CONTEXT7_OPS
    {CMD_ANSIBLE, CMD_MOLECULE, CMD_TERRAFORM, CMD_TERRAGRUNT, CMD_PULUMI, CMD_DOCKER, CMD_GH, CMD_GIT}, % DEVOPS
    {}, % DOCS_EDITOR
    {CMD_GH, CMD_GIT}, % ELITE
    {}, % FACT_OPS
    {CMD_GH}, % GITHUB_OPS
    {}, % KEEPER
    {}, % PLAN_REVIEWER
    {CMD_PYTHON, CMD_JINJA2, CMD_GH, CMD_GIT}, % PYTHON_DEV
    {}, % SECURITY_AUDITOR
    {CMD_MOLECULE, CMD_NPM_TEST, CMD_PYTEST, CMD_GH, CMD_GIT}, % TESTER
    {}, % WEAVER
    {} % MANAGER
];

% --- State Variables ---
% Representing what the action.yml actually provisions
array[AGENTS] of set of SKILLS: provisioned_skills = [
    if global_skills_path_provisioning then { s | s in SKILLS } else required_skills[a] endif
    | a in AGENTS
];

array[AGENTS] of set of TOOLS: provisioned_tools = required_tools;
array[AGENTS] of set of BASH_CMDS: provisioned_bash = required_bash;

bool: principle_of_least_privilege_maintained = (
    forall(a in AGENTS)(provisioned_skills[a] == required_skills[a]) /\
    forall(a in AGENTS)(provisioned_tools[a] == required_tools[a]) /\
    forall(a in AGENTS)(provisioned_bash[a] == required_bash[a])
);

bool: is_globally_dumping_runner_temp_skills_flawed = (
    exists(a in AGENTS)(provisioned_skills[a] != required_skills[a])
);

bool: isolated_environment_integrity = (
    principle_of_least_privilege_maintained /\
    (not (SKILL_GH_MODELS in provisioned_skills[CODE_REVIEWER])) % Example invariant
);

% --- Protocol State Variables ---
var 0..MAX_STEPS: current_step_count;
var 0..MAX_TOOL_CALLS: current_tool_calls;
var 0..MAX_TOKEN_BUDGET: current_token_usage;
var 0..MAX_TIME_TTL: elapsed_time;
var 0..MAX_PARTITION_STEPS: partition_size;
var 0..MAX_REPETITION: repetition_count;

var bool: is_budget_exhausted;
var bool: loop_arrest_triggered;

% Protocol Signals
var bool: has_progress_or_growth;
var bool: has_memo_hit;

% Global Invariants & Enforcements
bool: immutable_plan_version = true; % Fixed parameter (Global_Invariants GI2)
var bool: guardrail_preflight_passed;

% --- Constraints ---

% 1. Global Budget Protocol
constraint is_budget_exhausted <-> (
    current_step_count >= MAX_STEPS \/
    current_tool_calls >= MAX_TOOL_CALLS \/
    current_token_usage >= MAX_TOKEN_BUDGET \/
    elapsed_time >= MAX_TIME_TTL
);

% 2. Loop Arrest Protocol v3
constraint loop_arrest_triggered <-> (
    repetition_count >= MAX_REPETITION \/
    has_memo_hit \/
    is_budget_exhausted \/
    not has_progress_or_growth
);

% 3. Guardrail Executor (Pre-flight)
constraint guardrail_preflight_passed <-> (
    not loop_arrest_triggered /\
    immutable_plan_version
);

% 4. Required tools and bash commands must be subsets of provisioned ones.
constraint forall(a in AGENTS)(
    required_tools[a] <= provisioned_tools[a] /\
    required_bash[a] <= provisioned_bash[a]
);

% --- Solve Directive ---
solve satisfy;

% --- Output ---
string: flaw_verdict = if is_globally_dumping_runner_temp_skills_flawed then "YES" else "NO" endif;

output [
  "Environment Isolation Intact: \(isolated_environment_integrity)\n",
  "Least Privilege Maintained: \(principle_of_least_privilege_maintained)\n",
  "Is globally dumping runner.temp/.skills flawed? \(flaw_verdict).\n",
  "Global Skills Path Provisioning (action.yml flaw active): \(global_skills_path_provisioning)\n"
];
