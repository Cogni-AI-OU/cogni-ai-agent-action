% AGENT_SKILLS_CONSTRAINTS.mzn
% Formal mapping of agent roles to required skills vs. available paths.
% Used to verify if action.yml provides strict principle of least privilege.

% --- Sets & Enums ---
enum AGENTS = { ARCHITECT, BRAIN_OPS, CODE_REVIEWER, DEVOPS, PLAN_REVIEWER, PYTHON_DEV, TESTER, FACT_OPS, CONTEXT7_OPS };
enum SKILLS = { GH, GH_API, GH_MODELS, GH_PR, MERMAID, MINIZINC };
enum TOOLS = { BASH, GLOB, READ, EDIT, SKILL };
enum BASH_CMDS = { ANSIBLE, MOLECULE, TERRAFORM, NPM_TEST, PYTEST, GH, GIT, PYTHON };

% --- Inputs from action.yml logic ---
% In action.yml, skills.paths is a global array injected into the opencode config.
% This implicitly gives ALL agents access to ALL skills discovered in that path.
array[AGENTS] of set of SKILLS: required_skills = [
    {GH, MERMAID, MINIZINC},            % ARCHITECT
    {GH, GH_API, GH_MODELS, GH_PR, MINIZINC}, % BRAIN_OPS
    {GH, GH_PR},                        % CODE_REVIEWER
    {GH, GH_API, MINIZINC},             % DEVOPS
    {GH, MERMAID},                      % PLAN_REVIEWER
    {GH},                               % PYTHON_DEV
    {GH},                               % TESTER
    {GH},                               % FACT_OPS
    {GH}                                % CONTEXT7_OPS
];

array[AGENTS] of set of TOOLS: required_tools = [
    {BASH, GLOB, READ, EDIT, SKILL},    % ARCHITECT
    {BASH, GLOB, READ, SKILL},          % BRAIN_OPS
    {GLOB, READ},                       % CODE_REVIEWER
    {BASH, GLOB, READ, SKILL},          % DEVOPS
    {GLOB, READ},                       % PLAN_REVIEWER
    {BASH, GLOB, READ, SKILL},          % PYTHON_DEV
    {BASH, GLOB, READ, SKILL},          % TESTER
    {GLOB, READ, SKILL},                % FACT_OPS
    {GLOB, READ, SKILL}                 % CONTEXT7_OPS
];

array[AGENTS] of set of BASH_CMDS: required_bash = [
    {GH, GIT},                          % ARCHITECT
    {GH, GIT},                          % BRAIN_OPS
    {},                                 % CODE_REVIEWER
    {ANSIBLE, MOLECULE, TERRAFORM, GH, GIT}, % DEVOPS
    {},                                 % PLAN_REVIEWER
    {PYTHON, GH, GIT},                  % PYTHON_DEV
    {MOLECULE, NPM_TEST, PYTEST, GH, GIT}, % TESTER
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
    provisioned_skills[a] = {GH, GH_API, GH_MODELS, GH_PR, MERMAID, MINIZINC}
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
    (not (GH_MODELS in provisioned_skills[CODE_REVIEWER])) % Example invariant
);

% --- Solve Directive ---
solve satisfy;

% Output formatting
output [
  "Environment Isolation Intact: \(isolated_environment_integrity)\n",
  "Least Privilege Maintained: \(principle_of_least_privilege_maintained)\n",
  "Is globally dumping runner.temp/.skills flawed? YES.\n"
];
