const verticalSpacingMultiplier = 1.5; // 1.0 = no space, 1.2 = 20% extra space
const canvas = document.getElementById("matrix-canvas");
const ctx = canvas.getContext("2d");

// --- Configuration ---
const characterSet = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
const density = 0.8; // How many columns to create (0 to 1). Higher is more dense.
const flickerChance = 0.02; // Chance for a character in a column to change (0 to 1).

// --- Depth Layer Properties ---
// Corrected the chances to sum up to 1.0
const layers = [
  { // Farthest layer (background)
    size: 12, speed: 1,
    trailColor: "rgba(0, 255, 70, 0.4)", // Dim green for the trail
    leadingCharColor: "rgba(100, 255, 120, 0.6)", // Slightly brighter for the head
    glow: false, chance: 0.35,
  },
  { // Middle layer (standard)
    size: 16, speed: 2.5,
    trailColor: "rgba(0, 255, 100, 0.7)", // Normal green
    leadingCharColor: "rgba(200, 255, 220, 0.9)", // Bright head
    glow: false, chance: 0.55, // Changed from 0.75 to make total chance 1.0
  },
  { // Closest layer (foreground)
    size: 22, speed: 5,
    trailColor: "rgba(100, 255, 150, 0.8)", // Bright trail
    leadingCharColor: "rgba(255, 255, 255, 1.0)", // Pure white for the head
    glow: true, chance: 0.10,
  },
];

let columns = [];
let animationFrameId = null;

// A class to represent a full column of falling characters
class RainColumn {
  constructor(x) {
    this.x = x;
    this.characters = [];
    this.reset();
  }

  // Set the column's properties and generate its characters
  reset() {
    this.y = -Math.random() * canvas.height * 1.5; // Start well above the screen
    this.length = Math.floor(Math.random() * (canvas.height / 25)) + 10; // Random column length

    // --- Assign Layer Properties ---
    const rand = Math.random();
    let cumulativeChance = 0;
    for (const layer of layers) {
      cumulativeChance += layer.chance;
      if (rand < cumulativeChance) {
        this.size = layer.size;
        this.speed = layer.speed;
        this.trailColor = layer.trailColor;
        this.leadingCharColor = layer.leadingCharColor;
        this.hasGlow = layer.glow;
        break;
      }
    }
    
    // --- Generate Characters for the Column ---
    this.characters = [];
    for (let i = 0; i < this.length; i++) {
        this.characters.push(characterSet.charAt(Math.floor(Math.random() * characterSet.length)));
    }
  }

  // Draw the entire column of characters onto the canvas
  draw() {
    for (let i = 0; i < this.characters.length; i++) {
      const char = this.characters[i];
      const yPos = this.y - (i * this.size*verticalSpacingMultiplier);

      // Don't draw characters that are off-screen
      if (yPos > canvas.height || yPos < 0) continue;

      // ENHANCEMENT: Check if this is the leading character
      const isLeading = (i === 0);
      
      ctx.font = `${this.size}px monospace`;
      ctx.fillStyle = isLeading ? this.leadingCharColor : this.trailColor;

      // Add a glow effect for the 'close' layer's leading character
      if (this.hasGlow && isLeading) {
        ctx.shadowColor = '#0fa';
        ctx.shadowBlur = 10;
      } else {
        ctx.shadowColor = 'transparent';
        ctx.shadowBlur = 0;
      }
      
      ctx.fillText(char, this.x, yPos);
    }
  }

  // Update the column's position and handle flickering
  update() {
    // ENHANCEMENT: Character flickering effect
    if (Math.random() < flickerChance) {
        const randomIndex = Math.floor(Math.random() * this.characters.length);
        this.characters[randomIndex] = characterSet.charAt(Math.floor(Math.random() * characterSet.length));
    }

    // Move the column down
    this.y += this.speed;

    // Reset the column if its *entire body* has moved off-screen
    if (this.y - (this.length * this.size) > canvas.height) {
      this.reset();
    }
  }
}

// --- Setup and Animation Loop ---
function setup() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  columns = [];
  const avgFontSize = (layers[0].size + layers[1].size + layers[2].size) / 3;
  const columnCount = Math.floor(canvas.width / avgFontSize * density);
  const columnWidth = canvas.width / columnCount;

  for (let i = 0; i < columnCount; i++) {
    columns.push(new RainColumn(i * columnWidth));
  }
}

function animate() {
  // 1. Draw the semi-transparent black rectangle for the fading trail effect.
  ctx.fillStyle = "rgba(0, 0, 0, 0.05)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  // 2. Update and draw each column.
  for (const column of columns) {
    column.update();
    column.draw();
  }

  // 3. Request the next frame to continue the loop.
  animationFrameId = requestAnimationFrame(animate);
}

// --- Flutter Interoperability (No changes here) ---
window.setMatrixVisibility = (visible) => {
  const targetOpacity = visible ? '1' : '0';
  if (canvas.style.opacity !== targetOpacity) {
    canvas.style.transition = 'opacity 0.5s ease-in-out';
    canvas.style.opacity = targetOpacity;
  }
  if (visible && !animationFrameId) {
    animate();
  } else if (!visible && animationFrameId) {
    cancelAnimationFrame(animationFrameId);
    animationFrameId = null;
  }
};

// --- Event Listeners and Initialization ---
window.addEventListener("resize", setup);
setup();
animate();