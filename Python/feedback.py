import pygame
import socket

LEFT = 3
RIGHT = 2
LEFT_STRING = 'Think Left'
RIGHT_STRING = 'Think Right'
IDLE_STRING = 'Think Idle'
ORIGINAL_X = 400
ORIGINAL_Y = 400
ORIGINAL_WIDTH = 50
ORIGINAL_HEIGHT = 50


class ExpectedDirections:
    def __init__(self, expected_lst):
        # todo - Noa might need to change this, might not be an actual list in the way that it is being sent, to parse
        #  it somehow
        self.expected_directions = expected_lst
        self.original_length = len(self.expected_directions)

    def get_next_direction(self):
        next_direction = self.expected_directions[0]
        self.expected_directions = self.expected_directions[1:]
        return next_direction

    def get_length_of_expected_directions_list(self):
        return self.original_length


def move_x_to_center():
    lst_of_colors = [green, black, green, black, green, black, green, black, green, black, green, black, red]
    for color in lst_of_colors:
        # completely fill the surface object with black color
        win.fill(black)
        # drawing object on screen
        pygame.draw.rect(win, color, (x, y, width, height))
        # it refreshes the window
        pygame.display.update()
        pygame.time.delay(500)
    pygame.time.delay(3000)


def get_run(num_of_iters):
    if num_of_iters < expect_directions.get_length_of_expected_directions_list():
        return True
    return False


def get_direction_string():
    next_direction = expect_directions.get_next_direction()
    if next_direction == LEFT:
        return LEFT_STRING
    if next_direction == RIGHT:
        return RIGHT_STRING
    return IDLE_STRING

def get_expected_list(conn):
    conn.sendall(b"next")
    data = conn.recv(1024)
    expected_list = []
    while get_pred(data) != -1:
        print(data)
        expected_list.append(get_pred(data))
        conn.sendall(b"next")
        data = conn.recv(1024)
    return expected_list
        
    

def get_pred(data):
    print(data)
    if data == b'left':
        return 3
    if data == b'right':
        return 2
    if data == b'idle':
        return 1
    return -1

if __name__ == '__main__':
    # activate the pygame library
    # initiate pygame and give permission to use pygame's functionality
    pygame.init()

    # create a font object
    # 1st parameter is the font file which is present in pygame
    # 2nd parameter is size of the font
    font = pygame.font.Font('freesansbold.ttf', 32)

    # define the RGB value for black, red, green color
    red = (255, 0, 0)
    black = (0, 0, 0)
    green = (0, 255, 0)

    # assigning values to X and Y variable
    X = 800
    Y = 200

    # create the display surface object of specific dimension..e(800, 800)
    win = pygame.display.set_mode((800, 800))

    # set the pygame window name
    pygame.display.set_caption("Moving rectangle")

    # object current co-ordinates
    x = 400
    y = 400

    # dimensions of the object
    width = 50
    height = 50

    # drawing object on screen
    pygame.draw.rect(win, red, (x, y, width, height))

    # Draws the surface object to the screen
    pygame.display.update()

    # velocity / speed of movement
    vel = 120

    # indicates pygame is running
    run = True

    iter_num = 0

    HOST = ''  # Symbolic name meaning all available interfaces
    PORT = 50007  # Arbitrary non-privileged port
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(1)
    conn, addr = s.accept()
    print('Connected by', addr)    
    expected_list = get_expected_list(conn)
    print(expected_list)
    expect_directions = ExpectedDirections(expected_list)
    conn.sendall(b"next")

    while run:
        iter_num += 1
        # create a text surface object, on which text is drawn on
        text = font.render(get_direction_string(), True, red, black)

        # create a rectangular object for the text surface object
        textRect = text.get_rect()

        # set the center of the rectangular object
        textRect.center = (X // 2, Y // 2)

        # copying the text surface object to the display surface object at the center coordinate
        win.blit(text, textRect)
        pygame.time.delay(3000)

        # Draws the surface object to the screen
        pygame.display.update()

        # creates time delay of 6000ms
        pygame.time.delay(6000)

        # receving data from matlab
        data = conn.recv(1024)
        direction = get_pred(data)
        print(direction)

        # iterate over the list of Event objects that was returned by pygame.event.get() method
        for event in pygame.event.get():

            # if event object type is QUIT then quitting the pygame and program
            if event.type == pygame.QUIT:
                # it will exit the while loop
                run = False

        # if should move left
        if direction == LEFT and x > 0:
            # decrement in x co-ordinate
            x -= vel

        # if should move right
        if direction == RIGHT and x < 800 - width:
            # increment in x co-ordinate
            x += vel

        # completely fill the surface object with black color
        win.fill(black)

        # drawing object on screen
        pygame.draw.rect(win, red, (x, y, width, height))

        # it refreshes the window
        pygame.display.update()

        # in case the object should be moved to the center of the screen
        if x <= 40 or x >= 760:
            pygame.time.delay(3000)
            x = 400
            move_x_to_center()

        run = get_run(iter_num) and run
        # sending to matlab 'next' for getting the next data
        conn.sendall(b"next")

    pygame.time.delay(6000)
    # closes the pygame window
    pygame.quit()
