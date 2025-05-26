#!/bin/bash
set -e

echo "Setting up development repositories..."

# Determine repo owner priority:
# 1. FORK_OWNER (set in devcontainer.json for local environments)
# 2. GITHUB_REPOSITORY (for Codespaces/CI environments)
# 3. mirror-and-mountain (default fallback)

REPO_OWNER="mirror-and-mountain" # Default fallback

if [ -n "$FORK_OWNER" ]; then
    REPO_OWNER="$FORK_OWNER"
    echo "Detected repository owner from FORK_OWNER environment variable: $REPO_OWNER"
elif [ -n "$GITHUB_REPOSITORY" ]; then
    REPO_OWNER=$(echo "$GITHUB_REPOSITORY" | cut -d'/' -f1)
    echo "Detected repository owner from GITHUB_REPOSITORY environment variable (Codespaces/CI): $REPO_OWNER"
else
    echo "Using default repository owner: $REPO_OWNER"
fi

echo "Repository owner for cloning: $REPO_OWNER"

# Directories
WP_THEMES_DIR="/var/www/html/wp/wp-content/themes"

# Define MEROS_THEME
if [ -z "$MEROS_THEME" ]; then
  echo "Error: MEROS_THEME environment variable is not set. Please set it to your main theme name (e.g., meros-blocks)."
  exit 1
fi

clone_repos() {
  local ITEMS=("${!1}")
  local TARGET_DIR=$2

  for item in "${ITEMS[@]}"; do
    local REPO_FORK="https://github.com/${REPO_OWNER}/${item}.git"
    local REPO_ORIGIN="https://github.com/mirror-and-mountain/${item}.git"
    local REPO_PATH="${TARGET_DIR}/${item}"

    echo "Cloning $item into $REPO_PATH"
    rm -rf "$REPO_PATH"

    if git clone "$REPO_FORK" "$REPO_PATH"; then
      echo "✅ Successfully cloned: $item"
    elif git clone "$REPO_ORIGIN" "$REPO_PATH"; then
      echo "✅ Cloned origin as fallback: $item"
    else
      echo "❌ Error: Failed to clone '$item' from both fork and origin."
    fi
  done
}

# Clone and Setup the Main Theme
if [ ! -d "$WP_THEMES_DIR" ]; then
  echo "WordPress themes directory does not exist. Attempting to create."
  mkdir -p "$WP_THEMES_DIR" || { echo "Error: Could not create $WP_THEMES_DIR"; exit 1; }
fi

echo "Cloning theme '$MEROS_THEME' into WordPress themes directory."
clone_repos MEROS_THEME[@] "$WP_THEMES_DIR"
# Install composer dependancies
cd $WP_THEMES_DIR/$MEROS_THEME
composer install --no-interaction --ansi --no-progress --optimize-autoloader

# Clone Frameworks
FRAMEWORKS=('meros-framework')
clone_repos FRAMEWORKS[@] "$WP_THEMES_DIR/$MEROS_THEME/vendor/mirror-and-mountain"

# Clone Theme Plugins
if [ -n "$MEROS_PLUGINS" ]; then
  IFS=',' read -ra PLUGINS_TO_CLONE <<< "$MEROS_PLUGINS"
  clone_repos PLUGINS_TO_CLONE[@] "$WP_THEMES_DIR/$MEROS_THEME/plugins"
fi

# Clone Theme Extensions
if [ -n "$MEROS_EXTENSIONS" ]; then
  IFS=',' read -ra EXTENSIONS_TO_CLONE <<< "$MEROS_EXTENSIONS"
  clone_repos EXTENSIONS_TO_CLONE[@] "$WP_THEMES_DIR/$MEROS_THEME/vendor/mirror-and-mountain"
fi

# Activate Theme
echo "Activating theme '$MEROS_THEME' using WP-CLI."
/usr/local/bin/wp theme activate "$MEROS_THEME" --path="/var/www/html/wp" || { echo "Error: Failed to activate theme '$MEROS_THEME'."; exit 1; }
echo "Theme '$MEROS_THEME' activated."

echo "Meros development environment setup complete."