import fs from 'fs';
import path from 'path';

const configPath = path.resolve('forge.config.js');
let content = fs.readFileSync(configPath, 'utf-8');

if (!(/packagerConfig:\s*{[^}]*icon\s*:/.test(content))) {
  content = content.replace(
    /packagerConfig:\s*{([\s\S]*?)}/,
    (match, inner) => {
      const newLine = `icon: 'icons/icon',\n    ${inner}`;
      return `packagerConfig: {\n    ${newLine}\n}`;
    }
  );
}

content = content.replace(
  /({\s*name:\s*['"]@electron-forge\/maker-deb['"],\s*config:\s*{)([^}]*)(})/,
  (match, start, middle, send) => {
    if (/options\s*:/.test(middle)) {
      return match;
    } else {
      const newConfig = `${start}\n    options: { icon: 'icons/1024x1024.png' },\n    ${middle}${send}`;
      return newConfig;
    }
  }
);

content = content.replace(
  /({\s*name:\s*['"]@electron-forge\/maker-squirrel['"],\s*config:\s*{)([^}]*)(})/,
  (match, start, middle, send) => {
    if (/options\s*:/.test(middle)) {
      return match;
    } else {
      const newConfig = `${start}\n    setupIcon: 'icons/icon.ico',\n    ${middle}${send}`;
      return newConfig;
    }
  }
);

content = content.replace(
  /({\s*name:\s*['"]@electron-forge\/maker-dmg['"],\s*config:\s*{)([^}]*)(})/,
  (match, start, middle, send) => {
    if (/options\s*:/.test(middle)) {
      return match;
    } else {
      const newConfig = `${start}\n    icon: 'icons/icon.icns',\n    ${middle}${send}`;
      return newConfig;
    }
  }
);
  
fs.writeFileSync(configPath, content, 'utf-8');
