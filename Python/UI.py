import pygame
import socket
import sys
import winsound

pygame.init()
class OnlineUI:
    def __init__(self):
        self.is_running = True
        self.screen_res = (800, 800)
        self.icon_width = 100
        self.icon_height = 100
        self.N_Voting = 5  # the number of predictions to get a decision
        self.segment_length = 3  # the length of each segment to classify in seconds
        self.background = pygame.transform.scale(pygame.image.load('background.png'), self.screen_res)
        self.objects = {'right': [], 'left': [], 'idle': []}
        self.objects_loc = {'right': [], 'left': [], 'idle': []}
        self.pred_num = 0
        pygame.display.set_caption('ON-LINE')
        self.window_surface = pygame.display.set_mode(self.screen_res)

        Font = pygame.font.SysFont('timesnewroman', 30)
        self.text1 = Font.render("Right", False, (255, 255, 255), (0, 0, 0))
        self.text2 = Font.render("Idle", False, (255, 255, 255), (0, 0, 0))
        self.text3 = Font.render("Left", False, (255, 255, 255), (0, 0, 0))
        self.textRect1 = self.text1.get_rect()
        self.textRect1.center = (self.screen_res[0] - 100, 50)
        self.textRect2 = self.text2.get_rect()
        self.textRect2.center = (self.screen_res[0] / 2, 50)
        self.textRect3 = self.text3.get_rect()
        self.textRect3.center = (100, 50)
# clock = pygame.time.Clock()

    def add_prediction(self, pred):
        """
        :param pred: int represent the prediction made by the classifier
        """
        pred2str = {1: 'right', 2: 'left', 3: "idle"}
        init_locs = {'right': (self.screen_res[0] - self.icon_width, self.screen_res[1]),
                     'left': (0, self.screen_res[1]), 'idle': (self.screen_res[0] / 2, self.screen_res[1])}
        pred = pred2str[pred]
        obj = pygame.transform.scale(pygame.image.load(f'{pred}.png').convert(), (self.icon_width, self.icon_height))
        self.objects[pred].append(obj)
        if not self.objects_loc[pred]:  # list is empty
            l = (init_locs[pred][0], init_locs[pred][1] - self.icon_height)
            self.objects_loc[pred].append(l)
        else:  # list not empty
            l = (self.objects_loc[pred][-1][0], self.objects_loc[pred][-1][1] - self.icon_height)
            self.objects_loc[pred].append(l)
        self.pred_num += 1  # add 1 to prediction counter

    def Voting(self):
        res = max(self.objects.keys(), key=lambda key: len(self.objects[key]))
        if res == 'right':
            pygame.draw.rect(self.window_surface, (255, 0, 0), self.textRect1, 2)
            pygame.display.set_caption('Tutorialspoint Logo')
            TPImage = pygame.image.load("help.gif").convert_alpha()
            # coordinates of the image
            x = 100;
            y = 200;
            self.window_surface.blit(TPImage, (x, y))
            # paint screen one time
            pygame.display.flip()
            filename = 'help-record.wav'
            winsound.PlaySound(filename, winsound.SND_FILENAME)
            pygame.time.delay(5000) 
            
        elif res == 'left':
            pygame.draw.rect(self.window_surface, (255, 0, 0), self.textRect3, 2)
        else:
            pygame.draw.rect(self.window_surface, (255, 0, 0), self.textRect2, 2)
        pygame.display.flip()
        pygame.time.delay(2000)  # pause the program for 2s
        return res

    def print_objects(self):
        for object_list, locs_list in zip(self.objects.values(), self.objects_loc.values()):  # iterate through : right, left, idle
            for object, loc in zip(object_list, locs_list):
                self.window_surface.blit(object, loc)
        pygame.display.update()

    def print_labels(self):
        self.window_surface.blit(self.text1, self.textRect1)
        self.window_surface.blit(self.text2, self.textRect2)
        self.window_surface.blit(self.text3, self.textRect3)
        pygame.display.update()

    def reset(self):
        self.objects = {'right': [], 'left': [], 'idle': []}
        self.objects_loc = {'right': [], 'left': [], 'idle': []}
        self.window_surface.fill((0, 0, 0))
        self.print_labels()
        self.pred_num = 0
        pygame.display.update()



    def check(self, ):

        # pygame.display.set_caption('Tutorialspoint Logo')
        # TPImage = pygame.image.load("C:/master/bci/protocol/help.gif")
        # # coordinates of the image
        # x = 10;
        # y = 20;
        # self.window_surface.blit(TPImage, (x, y))
        # # paint screen one time
        # pygame.display.flip()

        pred_idx = 0
        self.print_labels()
        HOST = ''                 # Symbolic name meaning all available interfaces
        PORT = 50007              # Arbitrary non-privileged port
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((HOST, PORT))
        s.listen(1)
        conn, addr = s.accept()
        print ('Connected by', addr)
        conn.sendall(b"next")
        print("send next ")
        while self.is_running:
            # time_delta = clock.tick(60) / 1000.0
            #receving data from matlab
            data = conn.recv(1024)
            #convert to 1,2,3 respectively
            pred = self.get_pred(data)
            print(pred)
            if pred == -1: #if send exit
                pygame.time.delay(5000)  # delay 5s to see everything ok
                self.is_running = False
                print(f' The final voting is {self.Voting()}')
                self.reset()  # reset the lists back
                pygame.quit()
                sys.exit()
                break
            
            pygame.time.delay(1000)  # pause the program for 2s
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.is_running = False
            # add prediction to list
            self.add_prediction(pred)
            pred_idx += 1
            # print objects to screen
            self.print_objects()
            
            if self.pred_num == self.N_Voting:
                print(f' The final voting is {self.Voting()}')
                self.reset()  # reset the lists back
                pygame.time.delay(1000)
            #sending to matlab 'next' for getting the next data
            conn.sendall(b"next")
            print("send next ")
                
            

    def get_pred(self, data):
        print(data)
        if data == b'left':
            return 2
        if data == b'right':
            return 1
        if data == b'idle':
            return 3
        return -1

if __name__ == "__main__" :  
    ui = OnlineUI()
    ui.check()


