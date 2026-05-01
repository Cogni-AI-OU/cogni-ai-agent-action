% CONSTRAINTS.mzn
% Formal mapping of agent roles to required skills vs. available paths.
% Used to verify if action.yml provides strict principle of least privilege.
% Also defines runtime bounds, budgets, and logical enforcing functions.

% --- Parameters (Budgets and Limits) ---
int: MAX_STEPS = 20;               % Gated by Global_Budget_Protocol (GBP1)
int: MAX_TOOL_CALLS = 100;         % Gated by Global_Budget_Protocol (GBP2)
int: MAX_TOKEN_BUDGET = 50000;     % Gated by Global_Budget_Protocol (GBP3)
int: MAX_TIME_TTL = 3600;          % Gated by Global_Budget_Protocol (GBP4) - seconds
int: MAX_REPETITION = 3;           % Gated by Loop_Arrest_Protocol (LAP2)
int: MAX_PARTITION_STEPS = 8;      % Gated by State-Compression Protocol (CP1)
int: HARD_CHECKPOINT_THRESHOLD = 5; % Gated by State-Compression Protocol (CP5)

% --- Sets & Enums ---
enum AGENTS = { ARCHITECT, BRAIN_OPS, CODE_REVIEWER, DEVOPS, GITHUB_OPS, PLAN_REVIEWER, PYTHON_DEV, TESTER, FACT_OPS, CONTEXT7_OPS };

enum SKILLS = {
    SKILL_ANSIBLE, SKILL_CONTEXT_AWARE_OPS, SKILL_FACT_WRITER, SKILL_GH, SKILL_GH_API,
    SKILL_GH_MODELS, SKILL_GH_PR, SKILL_GH_RUN, SKILL_GIT, SKILL_GIT_EXPERT,
    SKILL_GITHUB, SKILL_GITHUB_ACTIONS, SKILL_GITHUB_SCRIPT, SKILL_MERMAID,
    SKILL_MERMAID_BETA, SKILL_MINIZINC, SKILL_MOLECULE, SKILL_PDF, SKILL_PRE_COMMIT,
    SKILL_ROBUST_COMMANDS, SKILL_SHELL, SKILL_SKILL_WRITER, SKILL_VIM_EX
};

enum TOOLS = { BASH, GLOB, READ, EDIT, SKILL, TASK, TODOWRITE };

enum BASH_CMDS = { CMD_ANSIBLE, CMD_MOLECULE, CMD_TERRAFORM, CMD_PULUMI, CMD_NPM_TEST, CMD_PYTEST, CMD_GH, CMD_GIT, CMD_PYTHON, CMD_DOCKER, CMD_JINJA2 };

% --- Model parameters (derived from action.yml) ---
% Flaw: skills.paths = ["${{ runner.temp }}/.skills"] gives ALL agents access to ALL discovered skills.
bool: global_skills_path_provisioning = true; 

% --- Requirements ---
array[AGENTS] of set of SKILLS: required_skills = [
    {SKILL_GH, SKILL_GIT, SKILL_MERMAID, SKILL_MINIZINC, SKILL_SHELL},            % ARCHITECT
    {SKILL_GH, SKILL_GH_API, SKILL_GH_MODELS, SKILL_GH_PR, SKILL_GH_RUN, SKILL_GIT, SKILL_GITHUB, SKILL_GITHUB_ACTIONS, SKILL_GITHUB_SCRIPT, SKILL_MINIZINC}, % BRAIN_OPS
    {SKILL_GH, SKILL_GH_PR, SKILL_GITHUB, SKILL_GIT},                            % CODE_REVIEWER
    {SKILL_GH, SKILL_GH_API, SKILL_GIT, SKILL_MINIZINC, SKILL_ANSIBLE, SKILL_MOLECULE, SKILL_SHELL}, % DEVOPS
    {SKILL_GH, SKILL_GH_API, SKILL_GH_PR, SKILL_GITHUB, SKILL_GIT},               % GITHUB_OPS
    {SKILL_GH, SKILL_GIT, SKILL_MERMAID, SKILL_MERMAID_BETA},                    % PLAN_REVIEWER
    {SKILL_GH, SKILL_GIT, SKILL_SHELL},                                          % PYTHON_DEV
    {SKILL_GH, SKILL_GIT, SKILL_MOLECULE, SKILL_SHELL},                          % TESTER
    {SKILL_GH, SKILL_GIT, SKILL_FACT_WRITER},                                    % FACT_OPS
    {SKILL_GH, SKILL_GIT, SKILL_CONTEXT_AWARE_OPS}                               % CONTEXT7_OPS
];

array[AGENTS] of set of TOOLS: required_tools = [
    {BASH, GLOB, READ, EDIT, SKILL, TASK, TODOWRITE},    % ARCHITECT
    {BASH, GLOB, READ, SKILL, TASK, TODOWRITE},          % BRAIN_OPS
    {GLOB, READ},                                        % CODE_REVIEWER
    {BASH, GLOB, READ, SKILL, TASK, TODOWRITE},          % DEVOPS
    {BASH, GLOB, READ, SKILL, TASK, TODOWRITE},          % GITHUB_OPS
    {GLOB, READ},                                        % PLAN_REVIEWER
    {BASH, GLOB, READ, SKILL, TASK, TODOWRITE},          % PYTHON_DEV
    {BASH, GLOB, READ, SKILL, TASK, TODOWRITE},          % TESTER
    {GLOB, READ, SKILL, TASK, TODOWRITE},                % FACT_OPS
    {GLOB, READ, SKILL, TASK, TODOWRITE}                 % CONTEXT7_OPS
];

array[AGENTS] of set of BASH_CMDS: required_bash = [
    {CMD_GH, CMD_GIT},                                                   % ARCHITECT
    {CMD_GH},                                                            % BRAIN_OPS
    {},                                                                  % CODE_REVIEWER
    {CMD_ANSIBLE, CMD_MOLECULE, CMD_TERRAFORM, CMD_PULUMI, CMD_DOCKER, CMD_GH, CMD_GIT}, % DEVOPS
    {CMD_GH},                                                            % GITHUB_OPS
    {},                                                                  % PLAN_REVIEWER
    {CMD_PYTHON, CMD_JINJA2, CMD_GH, CMD_GIT},                           % PYTHON_DEV
    {CMD_MOLECULE, CMD_NPM_TEST, CMD_PYTEST, CMD_GH, CMD_GIT},           % TESTER
    {},                                                                  % FACT_OPS
    {}                                                                   % CONTEXT7_OPS
];

% --- State Variables ---
% Representing what the action.yml actually provisions
array[AGENTS] of set of SKILLS: provisioned_skills;
array[AGENTS] of set of TOOLS: provisioned_tools;
array[AGENTS] of set of BASH_CMDS: provisioned_bash;

var bool: principle_of_least_privilege_maintained;
var bool: isolated_environment_integrity;
var bool: is_globally_dumping_runner_temp_skills_flawed;

% --- Constraints ---

% 1. Provisioning Logic (Reflecting action.yml configuration)
constraint forall(a in AGENTS)(
    if global_skills_path_provisioning then
        % Flaw: All agents get everything in the skills path
        provisioned_skills[a] = { s | s in SKILLS }
    else
        % Fixed: Provisioning is restricted to what's required (or explicitly allowed)
        provisioned_skills[a] = required_skills[a]
    endif
);

% Tool and Bash provisioning (modeled based on action.yml overrides)
% Required sets must be subsets of provisioned sets.
% Note: Using subset or == to represent subseteq logic.
constraint forall(a in AGENTS)(
    (required_tools[a] subset provisioned_tools[a] \/ required_tools[a] == provisioned_tools[a]) /\
    (required_bash[a] subset provisioned_bash[a] \/ required_bash[a] == provisioned_bash[a])
);

% For the sake of this model, we assume provisioned tools/bash match exactly what's required
% UNLESS inherited from default.
constraint forall(a in AGENTS)(
    provisioned_tools[a] = required_tools[a] /\
    provisioned_bash[a] = required_bash[a]
);

% 2. Principle of Least Privilege
% An agent should only be provisioned the exact skills/tools/bash it requires, no more.
constraint principle_of_least_privilege_maintained <-> (
    forall(a in AGENTS)(provisioned_skills[a] == required_skills[a]) /\
    forall(a in AGENTS)(provisioned_tools[a] == required_tools[a]) /\
    forall(a in AGENTS)(provisioned_bash[a] == required_bash[a])
);

% 3. Vulnerability Map
constraint is_globally_dumping_runner_temp_skills_flawed <-> (
    exists(a in AGENTS)(provisioned_skills[a] != required_skills[a])
);

% If isolated integrity is violated, it means an agent has access to skills it shouldn't.
constraint isolated_environment_integrity <-> (
    principle_of_least_privilege_maintained /\
    (not (SKILL_GH_MODELS in provisioned_skills[CODE_REVIEWER])) % Example invariant
);

% --- Solve Directive ---
solve satisfy;

% --- Protocol State Variables ---
var 0..MAX_STEPS: current_step_count;
var 0..MAX_TOOL_CALLS: current_tool_calls;
var 0..MAX_TOKEN_BUDGET: current_token_usage;
var 0..MAX_TIME_TTL: elapsed_time;
var 0..MAX_PARTITION_STEPS: partition_size;
var 0..MAX_REPETITION: repetition_count;

var bool: is_budget_exhausted;
var bool: loop_arrest_triggered;

constraint is_budget_exhausted <-> (
    current_step_count >= MAX_STEPS \/
    current_tool_calls >= MAX_TOOL_CALLS \/
    current_token_usage >= MAX_TOKEN_BUDGET \/
    elapsed_time >= MAX_TIME_TTL
);

% Output formatting
output [
  "Environment Isolation Intact: \(isolated_environment_integrity)\n",
  "Least Privilege Maintained: \(principle_of_least_privilege_maintained)\n",
  "Is globally dumping runner.temp/.skills flawed? \(is_globally_dumping_runner_temp_skills_flawed ? "YES" : "NO").\n",
  "Global Skills Path Provisioning (action.yml flaw active): \(global_skills_path_provisioning)\n"
];
