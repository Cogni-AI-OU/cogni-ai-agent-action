% AGENT_SKILLS_CONSTRAINTS.mzn
% Formal mapping of agent roles to required skills vs. available paths.
% Used to verify if action.yml provides strict principle of least privilege.

% --- Sets & Enums ---
enum AGENTS = { ARCHITECT, BRAIN_OPS, CODE_REVIEWER, DEVOPS, GITHUB_OPS, PLAN_REVIEWER, PYTHON_DEV, TESTER, FACT_OPS, CONTEXT7_OPS };

% Current skills available in the project (from .skills directory)
enum SKILLS = { 
    SKILL_ANSIBLE, SKILL_CONTEXT_AWARE_OPS, SKILL_FACT_WRITER, SKILL_GH, SKILL_GH_API, 
    SKILL_GH_MODELS, SKILL_GH_PR, SKILL_GH_RUN, SKILL_GIT, SKILL_GIT_EXPERT, 
    SKILL_GITHUB, SKILL_GITHUB_ACTIONS, SKILL_GITHUB_SCRIPT, SKILL_MERMAID, 
    SKILL_MERMAID_BETA, SKILL_MINIZINC, SKILL_MOLECULE, SKILL_PDF, SKILL_PRE_COMMIT, 
    SKILL_ROBUST_COMMANDS, SKILL_SHELL, SKILL_SKILL_WRITER, SKILL_VIM_EX 
};

enum TOOLS = { BASH, GLOB, READ, EDIT, SKILL };
enum BASH_CMDS = { CMD_ANSIBLE, CMD_MOLECULE, CMD_TERRAFORM, CMD_PULUMI, CMD_NPM_TEST, CMD_PYTEST, CMD_GH, CMD_GIT, CMD_PYTHON };

% --- Model parameters (derived from action.yml) ---
% Flaw: skills.paths = ["${{ runner.temp }}/.skills"] gives ALL agents access to ALL discovered skills.
bool: global_skills_path_provisioning = true; 

% --- Requirements ---
array[AGENTS] of set of SKILLS: required_skills = [
    {SKILL_GH, SKILL_MERMAID, SKILL_MINIZINC},            % ARCHITECT
    {SKILL_GH, SKILL_GH_API, SKILL_GH_MODELS, SKILL_GH_PR, SKILL_MINIZINC}, % BRAIN_OPS
    {SKILL_GH, SKILL_GH_PR},                        % CODE_REVIEWER
    {SKILL_GH, SKILL_GH_API, SKILL_MINIZINC},             % DEVOPS
    {SKILL_GH, SKILL_GH_API, SKILL_GH_PR},                % GITHUB_OPS
    {SKILL_GH, SKILL_MERMAID},                      % PLAN_REVIEWER
    {SKILL_GH},                               % PYTHON_DEV
    {SKILL_GH},                               % TESTER
    {SKILL_GH},                               % FACT_OPS
    {SKILL_GH}                                % CONTEXT7_OPS
];

array[AGENTS] of set of TOOLS: required_tools = [
    {BASH, GLOB, READ, EDIT, SKILL},    % ARCHITECT
    {BASH, GLOB, READ, SKILL},          % BRAIN_OPS
    {GLOB, READ},                       % CODE_REVIEWER
    {BASH, GLOB, READ, SKILL},          % DEVOPS
    {BASH, GLOB, READ, SKILL},          % GITHUB_OPS
    {GLOB, READ},                       % PLAN_REVIEWER
    {BASH, GLOB, READ, SKILL},          % PYTHON_DEV
    {BASH, GLOB, READ, SKILL},          % TESTER
    {GLOB, READ, SKILL},                % FACT_OPS
    {GLOB, READ, SKILL}                 % CONTEXT7_OPS
];

array[AGENTS] of set of BASH_CMDS: required_bash = [
    {CMD_GH, CMD_GIT},                          % ARCHITECT
    {CMD_GH, CMD_GIT},                          % BRAIN_OPS
    {},                                 % CODE_REVIEWER
    {CMD_ANSIBLE, CMD_MOLECULE, CMD_TERRAFORM, CMD_PULUMI, CMD_GH, CMD_GIT}, % DEVOPS
    {CMD_GH},                           % GITHUB_OPS
    {},                                 % PLAN_REVIEWER
    {CMD_PYTHON, CMD_GH, CMD_GIT},                  % PYTHON_DEV
    {CMD_MOLECULE, CMD_NPM_TEST, CMD_PYTEST, CMD_GH, CMD_GIT}, % TESTER
    {},                                 % FACT_OPS
    {}                                  % CONTEXT7_OPS
];

% --- State Variables ---
% Representing what the action.yml actually provisions
array[AGENTS] of set of SKILLS: provisioned_skills;
array[AGENTS] of set of TOOLS: provisioned_tools;
array[AGENTS] of set of BASH_CMDS: provisioned_bash;

var bool: principle_of_least_privilege_maintained;
var bool: isolated_environment_integrity;

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
% If isolated integrity is violated, it means an agent has access to skills it shouldn't.
constraint isolated_environment_integrity <-> (
    principle_of_least_privilege_maintained /\
    (not (SKILL_GH_MODELS in provisioned_skills[CODE_REVIEWER])) % Example invariant
);

% --- Solve Directive ---
solve satisfy;

% Output formatting
output [
  "Environment Isolation Intact: \(isolated_environment_integrity)\n",
  "Least Privilege Maintained: \(principle_of_least_privilege_maintained)\n",
  "Global Skills Path Provisioning (action.yml flaw active): \(global_skills_path_provisioning)\n"
];
