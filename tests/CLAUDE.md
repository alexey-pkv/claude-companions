# Windows Scripts Test Plan - Team Edition

This test plan validates the functionality of the Windows PowerShell scripts for Claude Companions installation and management using a coordinated team approach.

## Team Organization

### Team Roles

#### 🧪 Test Runner (Primary)
**Responsibilities:**
- Execute the complete test suite systematically
- Document all test results with detailed logs
- Maintain test environment cleanliness between test runs
- Create standardized issue reports for any failures
- Coordinate with fix teams on reproduction steps

#### 🔧 Installation Script Specialist
**Responsibilities:**
- Fix issues in `install.ps1`
- Handle file operations, directory creation, and settings.json manipulation
- Improve error handling and edge case management
- Validate fixes against test requirements

#### 🗑️ Uninstallation Script Specialist
**Responsibilities:**
- Fix issues in `uninstall.ps1`
- Ensure clean removal and settings.json cleanup
- Handle graceful missing component scenarios
- Validate complete cleanup procedures

#### 🎭 Rotation Script Specialist
**Responsibilities:**
- Fix issues in `rotate-tone.ps1`
- Handle UTF-8 encoding and special characters
- Improve random selection and edge case handling
- Ensure proper script integration

### Team Workflow

1. **Test Runner** executes full test suite and creates issue reports
2. **Specialists** work on fixes in parallel based on their area of expertise
3. **Test Runner** validates fixes and reports back
4. **Repeat** until all tests pass

### Communication Protocol

- Each team member creates detailed logs of their work
- Issues are tracked with specific test case references
- Fixes are validated before being marked complete
- Final validation requires full test suite re-run

## Prerequisites

- Windows machine with PowerShell 5.1 or later
- Execute permission for PowerShell scripts (may need to run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`)
- Clean test environment (no existing `.claude` directory or backup existing one)
- Git repository cloned with all files present

## Test Environment Setup

**Before each major test section:**
1. Remove existing `.claude` directory: `Remove-Item -Path "$env:USERPROFILE\.claude" -Recurse -Force -ErrorAction SilentlyContinue`
2. Verify repo structure is intact
3. Navigate to the `scripts\windows` directory

## Test Sections

### 1. Install Script Basic Functionality

#### Test 1.1: Help/Usage Display
**Command:** `.\install.ps1`
**Expected:** Usage message with all available switches displayed

#### Test 1.2: Install Single Tone - Valid
**Commands:**
```powershell
.\install.ps1 -Tone "gordon-ramsay"
.\install.ps1 -Tone "churchill"
```
**Expected:**
- Creates `%USERPROFILE%\.claude\tones\` directory
- Copies `gordon-ramsay.md` and `churchill.md` to destination
- Success messages displayed
- Files content matches source

#### Test 1.3: Install Single Tone - Invalid
**Command:** `.\install.ps1 -Tone "nonexistent-tone"`
**Expected:** Error message "Tone 'nonexistent-tone' not found in repo"

#### Test 1.4: Install All Tones
**Command:** `.\install.ps1 -Tones`
**Expected:**
- All 56+ tone files copied to `%USERPROFILE%\.claude\tones\`
- Success message with count
- All files match source content

#### Test 1.5: Install Session Hook
**Command:** `.\install.ps1 -Hook`
**Expected:**
- Creates `%USERPROFILE%\.claude\scripts\rotate-tone.ps1` (copy of source)
- Creates or modifies `%USERPROFILE%\.claude\settings.json`
- Hook entry added to `hooks.SessionStart` array
- JSON structure is valid
- Hook command points to correct script path

#### Test 1.6: Install Tone Skill
**Command:** `.\install.ps1 -ToneSkill`
**Expected:**
- Creates `%USERPROFILE%\.claude\skills\tone\SKILL.md`
- File content matches source `skills\tone\SKILL.md`

#### Test 1.7: Install Create-Tone Skill
**Command:** `.\install.ps1 -CreateSkill`
**Expected:**
- Creates `%USERPROFILE%\.claude\skills\create-tone\SKILL.md`
- File content matches source `skills\create-tone\SKILL.md`

#### Test 1.8: Install All Components
**Command:** `.\install.ps1 -All`
**Expected:**
- All tones installed
- Hook installed and configured
- Both skills installed
- All directories created
- Success message for complete installation

### 2. Install Script Edge Cases

#### Test 2.1: Existing Settings.json - Valid
**Setup:** Create a valid `settings.json` with other content
**Command:** `.\install.ps1 -Hook`
**Expected:** Hook added without corrupting existing settings

#### Test 2.2: Existing Settings.json - Malformed
**Setup:** Create malformed `settings.json`
**Command:** `.\install.ps1 -Hook`
**Expected:** Warning about parsing, creates fresh settings with hook

#### Test 2.3: Hook Already Exists
**Setup:** Install hook once
**Command:** `.\install.ps1 -Hook`
**Expected:** No duplicate entries, clean install

#### Test 2.4: Partial Existing Installation
**Setup:** Install some tones manually
**Command:** `.\install.ps1 -Tones`
**Expected:** All tones present, no errors, existing files overwritten

#### Test 2.5: Multiple Parameters
**Command:** `.\install.ps1 -Tones -Hook -ToneSkill`
**Expected:** All three components installed successfully

### 3. Uninstall Script Functionality

#### Test 3.1: Uninstall Help/Usage
**Command:** `.\uninstall.ps1`
**Expected:** Usage message with all available switches

#### Test 3.2: Uninstall Single Tone - Exists
**Setup:** Install gordon-ramsay tone
**Command:** `.\uninstall.ps1 -Tone "gordon-ramsay"`
**Expected:**
- File removed from `.claude\tones\`
- Success message
- Other tones remain if present

#### Test 3.3: Uninstall Single Tone - Not Exists
**Command:** `.\uninstall.ps1 -Tone "nonexistent"`
**Expected:** Message "Tone 'nonexistent' is not installed"

#### Test 3.4: Uninstall All Tones
**Setup:** Install multiple tones
**Command:** `.\uninstall.ps1 -Tones`
**Expected:**
- Entire `tones` directory removed
- Success message

#### Test 3.5: Uninstall All Tones - None Exist
**Command:** `.\uninstall.ps1 -Tones`
**Expected:** Message "No tones installed"

#### Test 3.6: Uninstall Hook
**Setup:** Install hook
**Command:** `.\uninstall.ps1 -Hook`
**Expected:**
- Hook entry removed from `settings.json`
- `rotate-tone.ps1` script removed
- Other settings preserved
- Clean JSON structure

#### Test 3.7: Uninstall Skills
**Setup:** Install both skills
**Commands:**
```powershell
.\uninstall.ps1 -ToneSkill
.\uninstall.ps1 -CreateSkill
```
**Expected:** Respective skill directories completely removed

#### Test 3.8: Uninstall All
**Setup:** Full installation
**Command:** `.\uninstall.ps1 -All`
**Expected:**
- All tones removed
- Hook removed and settings cleaned
- All skills removed
- Success message

### 4. Rotate-Tone Script Functionality

#### Test 4.1: Rotate with Available Tones
**Setup:** Install several tones
**Command:** `powershell -File "%USERPROFILE%\.claude\scripts\rotate-tone.ps1"`
**Expected:**
- Random tone selected and displayed
- Proper UTF-8 encoding (emoji displays correctly)
- Full tone content output
- Exit code 0

#### Test 4.2: Rotate with No Tones Directory
**Setup:** Ensure no `.claude\tones` directory exists
**Command:** `powershell -File rotate-tone.ps1`
**Expected:** Script exits gracefully with code 0, no output

#### Test 4.3: Rotate with Empty Tones Directory
**Setup:** Create empty `.claude\tones` directory
**Command:** `powershell -File "%USERPROFILE%\.claude\scripts\rotate-tone.ps1"`
**Expected:** Script exits gracefully with code 0, no output

#### Test 4.4: UTF-8 Character Handling
**Setup:** Install tones with special characters
**Command:** `powershell -File "%USERPROFILE%\.claude\scripts\rotate-tone.ps1"`
**Expected:** Special characters display correctly

### 5. Integration Tests

#### Test 5.1: Full Workflow
```powershell
# Install everything
.\install.ps1 -All

# Verify installation
dir "%USERPROFILE%\.claude" -Recurse

# Test tone rotation multiple times
1..5 | ForEach-Object { powershell -File "%USERPROFILE%\.claude\scripts\rotate-tone.ps1"; Write-Host "---" }

# Partial uninstall
.\uninstall.ps1 -Tones

# Verify tones gone but others remain
dir "%USERPROFILE%\.claude" -Recurse

# Full uninstall
.\uninstall.ps1 -All

# Verify clean state
Test-Path "%USERPROFILE%\.claude"
```

#### Test 5.2: Reinstall Over Existing
**Setup:** Full installation
**Command:** `.\install.ps1 -All`
**Expected:** Clean reinstall, no duplicate entries, all files updated

#### Test 5.3: Hook Integration Test
**Setup:** Install hook
**Test:** Start new Claude session (if possible)
**Expected:** Random tone displayed at session start

### 6. Error Handling and Edge Cases

#### Test 6.1: Insufficient Permissions
**Setup:** Make destination directory read-only
**Command:** `.\install.ps1 -Tones`
**Expected:** Graceful error handling

#### Test 6.2: Disk Space Issues
**Setup:** Fill disk (if safe to test)
**Command:** `.\install.ps1 -Tones`
**Expected:** Appropriate error messages

#### Test 6.3: Missing Source Files
**Setup:** Temporarily move a tone file
**Command:** `.\install.ps1 -Tone "moved-tone"`
**Expected:** Error message about missing source

#### Test 6.4: Corrupted Settings JSON During Uninstall
**Setup:** Install hook, then corrupt `settings.json`
**Command:** `.\uninstall.ps1 -Hook`
**Expected:** Warning message, graceful handling

### 7. Validation Checks

For each successful operation, verify:

#### File System Checks
- Correct directory structure created
- Files copied completely (compare file sizes/hashes)
- Proper file permissions
- UTF-8 encoding preserved

#### Settings.json Validation
- Valid JSON structure
- Proper hook format and paths
- No duplicate entries
- Backwards compatibility maintained

#### Script Content Verification
- `rotate-tone.ps1` copied correctly
- Executable permissions maintained
- Cross-references work correctly

## Team Coordination

### Issue Tracking Template

When the Test Runner finds issues, use this template:

```
**Issue ID:** [SCRIPT]-[TEST#]-[BRIEF_DESCRIPTION]
**Test Case:** [Specific test case reference]
**Script:** install.ps1 | uninstall.ps1 | rotate-tone.ps1
**Severity:** Critical | High | Medium | Low
**Assigned to:** [Specialist role]

**Description:**
[Detailed description of the issue]

**Steps to Reproduce:**
1. [Step-by-step reproduction]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happened]

**Environment:**
- PowerShell Version: [version]
- Windows Version: [version]
- Test Environment State: [clean/existing data]

**Logs:**
[Relevant command output/error messages]
```

### Fix Validation Process

1. **Specialist** implements fix and tests locally
2. **Specialist** documents changes made and rationale
3. **Test Runner** validates fix by re-running affected test cases
4. **Test Runner** marks issue as resolved or provides additional feedback

### Progress Tracking

Each team member should update their progress:
- **Started:** When beginning work on an assigned area
- **Blocked:** If waiting for dependencies or encountering obstacles
- **Testing:** When fix is ready for validation
- **Complete:** When all assigned issues are resolved and validated

## Test Execution Notes

### Running the Tests

1. **Sequential Execution:** Run tests in order, with environment cleanup between major sections
2. **Parallel Testing:** Some tests can run in parallel with separate user accounts
3. **Automation:** Consider PowerShell Pester framework for automated testing

### Expected Pass Criteria

- All file operations complete successfully
- No PowerShell errors or exceptions
- JSON files remain valid
- Scripts execute without syntax errors
- Cross-script integration works (hook calls rotate script successfully)
- Unicode/UTF-8 handling works correctly
- Cleanup operations leave system in expected state

### Logging

For each test, capture:
- Command executed
- Exit code
- stdout/stderr output
- File system state before/after
- Settings.json content before/after

## Known Issues to Test For

Based on the code analysis, pay special attention to:

1. **PowerShell Execution Policy** - May block script execution
2. **JSON Parsing Errors** - Settings.json corruption scenarios
3. **Path Handling** - Spaces in usernames/paths
4. **UTF-8 Encoding** - Special characters in tone files
5. **Concurrent Access** - Multiple scripts modifying same files
6. **Long Paths** - Windows path length limitations

## Success Criteria

The Windows scripts pass testing if:
- All core functionality works as documented
- Error handling is graceful and informative
- No data corruption occurs
- Scripts integrate properly with Claude Code
- Performance is acceptable for typical use cases
- Cross-platform compatibility maintained with Unix equivalents