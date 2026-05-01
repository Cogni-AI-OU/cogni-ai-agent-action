% CONSTRAINTS.mzn
% Formal mapping of agent roles to required skills vs. available paths.
% Used to verify if action.yml provides strict principle of least privilege.

% --- Sets & Enums ---
enum AGENTS = { ARCHITECT, BRAIN_OPS, CODE_REVIEWER, DEVOPS, GITHUB_OPS, PLAN_REVIEWER, PYTHON_DEV, TESTER, FACT_OPS, CONTEXT7_OPS };
enum SKILLS = { SKILL_GH, SKILL_GH_API, SKILL_GH_MODELS, SKILL_GH_PR, SKILL_MERMAID, SKILL_MINIZINC };
enum TOOLS = { BASH, GLOB, READ, EDIT, SKILL };
enum BASH_CMDS = { CMD_ANSIBLE, CMD_MOLECULE, CMD_TERRAFORM, CMD_PULUMI, CMD_NPM_TEST, CMD_PYTEST, CMD_GH, CMD_GIT, CMD_PYTHON };

% --- Inputs from action.yml logic ---
% In action.yml, skills.paths is a global array injected into the opencode config.
% This implicitly gives ALL agents access to ALL skills discovered in that path.
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

% 1. Global Provisioning Check (action.yml structural flaw)
% Because `skills.paths = ["${{ runner.temp }}/.skills"]` is evaluated without
% referencing the `AGENT_NAME` variable, EVERY agent gets the union of ALL skills.
constraint forall(a in AGENTS)(
    provisioned_skills[a] = {SKILL_GH, SKILL_GH_API, SKILL_GH_MODELS, SKILL_GH_PR, SKILL_MERMAID, SKILL_MINIZINC}
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
% If brain-ops requires gh-models, but a reviewer suddenly gains access
% to gh-models purely because it shares the runner.temp/.skills path,
% we violate the isolation constraint.
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
  "Is globally dumping runner.temp/.skills flawed? YES.\n"
];
