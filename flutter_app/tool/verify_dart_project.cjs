const fs = require('fs');
const path = require('path');

const libDir = path.join(__dirname, '..', 'lib');

function getAllFiles(dirPath, arrayOfFiles = []) {
  const files = fs.readdirSync(dirPath);
  files.forEach((file) => {
    const fullPath = path.join(dirPath, file);
    if (fs.statSync(fullPath).isDirectory()) {
      getAllFiles(fullPath, arrayOfFiles);
    } else if (file.endsWith('.dart')) {
      arrayOfFiles.push(fullPath);
    }
  });
  return arrayOfFiles;
}

const dartFiles = getAllFiles(libDir);
console.log(`Found ${dartFiles.length} Dart files to analyze.\n`);

let totalErrors = 0;
let totalWarnings = 0;

dartFiles.forEach((filePath) => {
  const relPath = path.relative(libDir, filePath);
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');

  // 1. Check brackets balance
  let openBraces = 0;
  let openParens = 0;
  let openBrackets = 0;
  let inBlockComment = false;

  for (let i = 0; i < lines.length; i++) {
    let line = lines[i];
    const trimmed = line.trim();

    // Check comment blocks
    if (trimmed.startsWith('/*')) inBlockComment = true;
    if (inBlockComment) {
      if (trimmed.includes('*/')) inBlockComment = false;
      continue;
    }
    if (trimmed.startsWith('//')) continue;

    // Check imports
    if (trimmed.startsWith("import '") || trimmed.startsWith('import "')) {
      const match = trimmed.match(/import\s+['"]([^'"]+)['"]/);
      if (match) {
        const importTarget = match[1];
        if (importTarget.startsWith('package:mahakhanij_consumer/')) {
          const subPath = importTarget.replace('package:mahakhanij_consumer/', '');
          const targetFull = path.join(libDir, subPath);
          if (!fs.existsSync(targetFull)) {
            console.error(`[ERROR] ${relPath}:${i + 1} - Missing package import: ${importTarget}`);
            totalErrors++;
          }
        } else if (importTarget.startsWith('.')) {
          const targetFull = path.resolve(path.dirname(filePath), importTarget);
          if (!fs.existsSync(targetFull)) {
            console.error(`[ERROR] ${relPath}:${i + 1} - Missing relative import: ${importTarget}`);
            totalErrors++;
          }
        }
      }
    }

    // Bracket balance checking
    let inSingleQuote = false;
    let inDoubleQuote = false;
    for (let charIdx = 0; charIdx < line.length; charIdx++) {
      const c = line[charIdx];
      const prev = charIdx > 0 ? line[charIdx - 1] : '';

      if (c === "'" && prev !== '\\' && !inDoubleQuote) inSingleQuote = !inSingleQuote;
      else if (c === '"' && prev !== '\\' && !inSingleQuote) inDoubleQuote = !inDoubleQuote;
      else if (!inSingleQuote && !inDoubleQuote) {
        if (c === '{') openBraces++;
        else if (c === '}') openBraces--;
        else if (c === '(') openParens++;
        else if (c === ')') openParens--;
        else if (c === '[') openBrackets++;
        else if (c === ']') openBrackets--;
      }
    }
  }

  if (openBraces !== 0) {
    console.error(`[ERROR] ${relPath} - Unbalanced curly braces: delta = ${openBraces}`);
    totalErrors++;
  }
  if (openParens !== 0) {
    console.error(`[ERROR] ${relPath} - Unbalanced parentheses: delta = ${openParens}`);
    totalErrors++;
  }
  if (openBrackets !== 0) {
    console.error(`[ERROR] ${relPath} - Unbalanced square brackets: delta = ${openBrackets}`);
    totalErrors++;
  }

  // 2. Common gotcha checks
  if (content.includes('withValues(')) {
    console.error(`[ERROR] ${relPath} - Uses 'withValues' which is only available in Flutter 3.27+. Use 'withOpacity'.`);
    totalErrors++;
  }
});

console.log(`\nAnalysis Completed: ${totalErrors} Errors, ${totalWarnings} Warnings.`);
if (totalErrors === 0) {
  console.log("SUCCESS: All Dart files have balanced syntax and all internal imports resolve cleanly!");
}
