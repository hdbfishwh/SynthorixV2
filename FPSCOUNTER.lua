import pygame
import sys

# Initialize Pygame
pygame.init()

# Screen dimensions
WIDTH, HEIGHT = 800, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("FPS and MS Counter")

# Colors
BACKGROUND = (15, 15, 25)
TEXT_COLOR = (180, 240, 180)
SHADOW_COLOR = (0, 30, 0)
UI_BG = (30, 35, 45)
UI_BORDER = (60, 80, 100)

# Font
font = pygame.font.SysFont("monospace", 24, bold=True)

# Clock for controlling frame rate
clock = pygame.time.Clock()

# For FPS calculation
frame_count = 0
start_time = pygame.time.get_ticks()
fps = 0
frame_time = 0

def draw_fps_counter():
    # Create background panel
    panel_width = 200
    panel_height = 50
    panel_x = (WIDTH - panel_width) // 2
    panel_y = 20
    
    # Draw panel background with border
    pygame.draw.rect(screen, UI_BG, (panel_x, panel_y, panel_width, panel_height), 0, 10)
    pygame.draw.rect(screen, UI_BORDER, (panel_x, panel_y, panel_width, panel_height), 3, 10)
    
    # Prepare text
    fps_text = f"FPS: {fps}"
    ms_text = f"MS: {frame_time:.1f}"
    
    # Render text with shadow effect
    shadow_offset = 1
    
    # Render FPS text
    fps_shadow = font.render(fps_text, True, SHADOW_COLOR)
    fps_surface = font.render(fps_text, True, TEXT_COLOR)
    screen.blit(fps_shadow, (panel_x + 20 + shadow_offset, panel_y + 15 + shadow_offset))
    screen.blit(fps_surface, (panel_x + 20, panel_y + 15))
    
    # Render MS text
    ms_shadow = font.render(ms_text, True, SHADOW_COLOR)
    ms_surface = font.render(ms_text, True, TEXT_COLOR)
    screen.blit(ms_shadow, (panel_x + 120 + shadow_offset, panel_y + 15 + shadow_offset))
    screen.blit(ms_surface, (panel_x + 120, panel_y + 15))

def draw_demo_content():
    # Draw some moving elements to make the FPS counter meaningful
    time = pygame.time.get_ticks() / 1000
    
    # Draw rotating rectangles
    for i in range(5):
        size = 50 + i * 20
        rotation = time * 0.5 + i * 0.5
        rect = pygame.Surface((size, size), pygame.SRCALPHA)
        pygame.draw.rect(rect, (40 + i * 20, 100, 150, 150), (0, 0, size, size))
        rotated_rect = pygame.transform.rotate(rect, rotation * 45)
        screen.blit(rotated_rect, (WIDTH // 2 - rotated_rect.get_width() // 2, 
                                  HEIGHT // 2 - rotated_rect.get_height() // 2))
    
    # Draw some bouncing circles
    for i in range(3):
        x = WIDTH // 2 + pygame.math.Vector2(1, 0).rotate(time * 100 + i * 120).x * 150
        y = HEIGHT // 2 + pygame.math.Vector2(0, 1).rotate(time * 80 + i * 90).y * 100
        radius = 20 + i * 10
        pygame.draw.circle(screen, (200, 70, 50), (int(x), int(y)), radius)

# Main game loop
running = True
while running:
    # Handle events
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                running = False
    
    # Clear the screen
    screen.fill(BACKGROUND)
    
    # Draw demo content
    draw_demo_content()
    
    # Calculate FPS and frame time
    frame_count += 1
    current_time = pygame.time.get_ticks()
    elapsed_time = current_time - start_time
    
    if elapsed_time > 1000:  # Update every second
        fps = frame_count
        frame_count = 0
        start_time = current_time
    
    # Get frame time (time since last frame)
    frame_time = clock.get_time()
    
    # Draw FPS counter
    draw_fps_counter()
    
    # Update the display
    pygame.display.flip()
    
    # Cap the frame rate
    clock.tick(60)

# Quit Pygame
pygame.quit()
sys.exit()
