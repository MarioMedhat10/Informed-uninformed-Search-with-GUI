import pyswip
import tkinter as tk
from PIL import ImageTk,Image

class GameGUI:

    def __init__(self, master):
        self.master = master
        self.master.title("Game GUI")
        
        # create input widgets
        self.row_label = tk.Label(self.master, text="Number of Rows:")
        self.row_label.grid(row=0, column=0)
        self.row_entry = tk.Entry(self.master)
        self.row_entry.grid(row=0, column=1)
        
        self.col_label = tk.Label(self.master, text="Number of Columns:")
        self.col_label.grid(row=1, column=0)
        self.col_entry = tk.Entry(self.master)
        self.col_entry.grid(row=1, column=1)

        self.b1x_label = tk.Label(self.master, text="Bomb 1 Row:")
        self.b1x_label.grid(row=2, column=0)
        self.b1x_entry = tk.Entry(self.master)
        self.b1x_entry.grid(row=2, column=1)

        self.b1y_label = tk.Label(self.master, text="Bomb 1 Column:")
        self.b1y_label.grid(row=3, column=0)
        self.b1y_entry = tk.Entry(self.master)
        self.b1y_entry.grid(row=3, column=1)

        self.b2x_label = tk.Label(self.master, text="Bomb 2 Row:")
        self.b2x_label.grid(row=4, column=0)
        self.b2x_entry = tk.Entry(self.master)
        self.b2x_entry.grid(row=4, column=1)

        self.b2y_label = tk.Label(self.master, text="Bomb 2 Column:")
        self.b2y_label.grid(row=5, column=0)
        self.b2y_entry = tk.Entry(self.master)
        self.b2y_entry.grid(row=5, column=1)

        # create run button
        self.run_button = tk.Button(self.master, text="Run", command=self.run_game)
        self.run_button.grid(row=6, column=1)

    def run_game(self):
        # get input values
        rows = int(self.row_entry.get())
        cols = int(self.col_entry.get())
        b1x = int(self.b1x_entry.get())
        b1y = int(self.b1y_entry.get())
        b2x = int(self.b2x_entry.get())
        b2y = int(self.b2y_entry.get())

        # create Prolog engine
        prolog = pyswip.Prolog()
        prolog.consult("assign 2 uninformed Search.pl") # load the Prolog code file

        # call the makeGame predicate and get the result
        result = list(prolog.query(f"makeGame({rows},{cols},{b1x},{b1y},{b2x},{b2y},MM)"))

        # print the result to console
        for board in result:
            new_window = tk.Toplevel(self.master)
            new_window.title("Game Result")

            print(board["MM"])

            for i in range(rows):
                for j in range(cols):
                    text_box = tk.Text(new_window,width=10,height=3)
                    text_box.grid(row=i,column=j)
                    if(str(board["MM"][i][j]) == str("b'*'")):
                        text_box.insert(tk.END, str("Bomb"))
                        text_box.configure(background="black")
                        text_box.config(fg="white",font=("Arial",13))
                    elif(str(board["MM"][i][j]) == str("b'v'")):
                        text_box.insert(tk.END, str("V"))
                        text_box.configure(background="red")
                        text_box.config(fg="white",font=("Arial",13))
                    elif(str(board["MM"][i][j]) == str("b'h'")):
                        text_box.insert(tk.END, str("H"))
                        text_box.configure(background="blue")
                        text_box.config(fg="white",font=("Arial",13))
                    else:
                        text_box.insert(tk.END, str("0"))
                        text_box.config(font=("Arial",13))

                    text_box.config(state='disabled')


# create the main window
root = tk.Tk()
game_gui = GameGUI(root)
root.mainloop()
