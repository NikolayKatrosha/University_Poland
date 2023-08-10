using Gtk
"""
    is_valid_sudoku(grid::Matrix{Int64}, row::Int, col::Int, num::Int)

Sprawdza czy umieszczenie podanej liczby w konkretnym wierszu, kolumnie i małym kwadracie 3x3 nie narusza zasad gry Sudoku.

# Argumenty
- 'grid::Matrix{Int64}': Siatka Sudoku reprezentowana jako macierz liczb całkowitych 9x9.
- 'row::Int': Indeks wiersza (1-9), w którym ma zostać umieszczona dana liczba.
- 'col::Int': Indeks kolumny (1-9), w którym ma zostać umieszczona dana liczba.
- 'num::Int': Liczba, która ma zostać umieszczona na pozycji ['row', 'col'].

# Zwraca
- 'true' jeśli umieszczenie 'num' na pozycji ['row', 'col'] jest poprawne zgodnie z zasadami Sudoku.
- 'false' w przeciwnym razie.

# Przykładc
```jldoctest
julia> grid = [
    9 0 0 8 3 0 1 0 0;
    0 0 1 5 0 0 0 0 0;
    0 0 6 0 1 7 0 2 8;
    0 0 0 1 6 9 3 8 4;
    1 6 0 0 0 0 0 9 0;
    0 0 0 0 0 0 0 1 0;
    0 6 0 2 5 0 8 4 0;
    0 0 8 0 0 0 9 0 2;
    3 0 2 4 0 8 0 0 0
]

julia> is_valid_sudoku(grid, 1, 3, 7)
true
julia> is_valid_sudoku(grid, 1, 3, 9)
false
```
"""
function is_valid_sudoku(grid::Matrix{Int64}, row::Int, col::Int, num::Int)
    grid_copy = deepcopy(grid)
    grid_copy[row, col] = 0
    if any(grid_copy[row, :] .== num) || any(grid_copy[:, col] .== num) || any(grid_copy[3 * div(row - 1, 3) + 1:3 * div(row - 1, 3) + 3, 3 * div(col - 1, 3) + 1:3 * div(col - 1, 3) + 3] .== num)
        return false
    else
        return true
    end
end



"""
    solve_sudoku(grid::Matrix{Int64})

Rekurencyjnie rozwiązuje daną siatka Sudoku używając algorytmu z nawrotami (backtracking).

# Argumenty
- 'grid::Matrix{Int64}': Siatka Sudoku reprezentowana jako macierz liczb całkowitych 9x9. Puste komórki są reprezentowane przez '0'.

# Zwraca
- Krotka '(status, solution)' gdzie
    - 'status::Bool':
        - 'true' jeśli zostanie znalezione prawidłowe rozwiązanie.
        - 'false' jeśli żadne rozwiązanie nie jest możliwe.
    - 'solution::Matrix{Int64}': Rozwiązana siatka Sudoku, jeśli zostanie znalezione rozwiązanie. W przeciwnym razie zwraca siatkę bez zmian.

# Przykład
```jldoctest
julia> grid = [
    0 0 6 8 9 1 0 0 3;
    3 0 9 7 0 6 0 0 0;
    0 7 0 0 0 5 0 2 0;
    0 0 0 9 1 3 5 6 8;
    0 0 0 6 8 0 0 0 0;
    0 8 0 0 0 0 0 0 7;
    1 0 0 0 0 0 0 0 5;
    7 0 0 0 3 8 0 0 0;
    0 0 0 1 0 0 7 3 0
]

julia> status, solution = solve_sudoku(grid)
(true, [2 5 … 7 3; 3 4 … 5 1; … ; 7 6 … 1 9; 5 9 … 3 4])
julia> status
true
julia> solution 
9x9 Matrix{Int64}:
 2  5  6  8  9  1  4  7  3
 3  4  9  7  2  6  8  5  1
 8  7  1  3  4  5  9  2  6
 4  2  7  9  1  3  5  6  8
 9  1  5  6  8  7  3  4  2
 6  8  3  2  5  4  1  9  7
 1  3  2  4  7  9  6  8  5
 7  6  4  5  3  8  2  1  9
 5  9  8  1  6  2  7  3  4
 ```
"""
function solve_sudoku(grid::Matrix{Int64})
    row = 0
    col = 0
    found = false
    for i in 1:9
        for j in 1:9
            if grid[i, j] == 0
                row = i
                col = j
                found = true
                break
            end
        end
        if found
            break
        end
    end

    if !found
        return true, grid
    end

    for num in 1:9
        if is_valid_sudoku(grid, row, col, num)
            grid[row, col] = num
            if solve_sudoku(grid)[1]
                return true, grid
            end
            grid[row, col] = 0
        end
    end

    return false, grid
end



"""
    fully_solved_grid()

Generuje i zwraca w pełni rozwiązaną siatkę Sudoku.

# Zwraca
- 'grid::Matrix{Int64}': macierz 9x9 reprezentująca w pełni rozwiązaną siatkę Sudoku.

# Przykład
```jldoctest
julia> grid = fully_solved_grid()
9x9 Matrix{Int64}:
 1  4  7  2  5  8  3  6  9
 2  5  8  3  6  9  4  7  1
 3  6  9  4  7  1  5  8  2
 4  7  1  5  8  2  6  9  3
 5  8  2  6  9  3  7  1  4
 6  9  3  7  1  4  8  2  5
 7  1  4  8  2  5  9  3  6
 8  2  5  9  3  6  1  4  7
 9  3  6  1  4  7  2  5  8
```
"""
function fully_solved_grid()
    grid = zeros(Int64, 9, 9)
    for i in 1:3
        for j in 1:3
            for num in 1:9
                grid[3 * (i - 1) + ((num - 1) % 3) + 1, 3 * (j - 1) + div((num - 1), 3) + 1] = (3 * (i - 1) + j + num - 2) % 9 + 1
            end
        end
    end

    return grid
end




"""
    transform_grid(grid::Matrix{Int64})

Przekształca podaną siatkę Sudoku przez losowe przestawianie wierszy i kolumn, które są z zakresu tego samego małego kwadratu 3x3.

# Argumenty
- 'grid::Matrix{Int64}': Siatka Sudoku reprezentowana jako macierz liczb całkowitych 9x9.

# Zwraca
- 'new_grid::Matrix{Int64}': Przekształcona siatka Sudoku uzyskana przez losowe permutowanie wierszy i kolumn wejściowej siatki.

# Przykład
```jldoctest
julia> grid = [
    1  4  7  2  5  8  3  6  9;
    2  5  8  3  6  9  4  7  1;
    3  6  9  4  7  1  5  8  2;
    4  7  1  5  8  2  6  9  3;
    5  8  2  6  9  3  7  1  4;
    6  9  3  7  1  4  8  2  5;
    7  1  4  8  2  5  9  3  6;
    8  2  5  9  3  6  1  4  7;
    9  3  6  1  4  7  2  5  8
]
julia> new_grid = transform_grid(grid)
9x9 Matrix{Int64}:
 9  3  6  1  4  7  2  8  5
 8  2  5  9  3  6  1  7  4
 7  1  4  8  2  5  9  6  3
 1  4  7  2  5  8  3  9  6
 3  6  9  4  7  1  5  2  8
 2  5  8  3  6  9  4  1  7
 5  8  2  6  9  3  7  4  1
 6  9  3  7  1  4  8  5  2
 4  7  1  5  8  2  6  3  9
```
"""
function transform_grid(grid::Matrix{Int64})
    new_grid = deepcopy(grid)

    for _ in 1:rand(1:20)
        row_group = rand(0:2)
        row1 = rand(1:3) + 3 * row_group
        row2 = rand(1:3) + 3 * row_group
        new_grid[[row1, row2], :] = new_grid[[row2, row1], :]

        col_group = rand(0:2)
        col1 = rand(1:3) + 3 * col_group
        col2 = rand(1:3) + 3 * col_group
        new_grid[:, [col1, col2]] = new_grid[:, [col2, col1]]
    end

    return new_grid
end



"""
    remove_cells(grid::Matrix{Int64}, num_cells_to_remove::Int, initial_difficulty::Int)

Usuwa określoną liczbę komórek z podanej siatki Sudoku, aby utworzyć łamigłówkę o żądanym poziomie trudności.

# Argumenty
- 'grid::Matrix{Int64}': Siatka Sudoku reprezentowana jako macierz liczb całkowitych 9x9.
- 'num_cells_to_remove::Int': Liczba komórek do usunięcia z `siatki`.
- 'initial_difficulty::Int': Pożądany początkowy poziom trudności łamigłowki. Służy do dostosowania liczby usuwanych komórek.

# Zwraca
- Krotka '(grid, difficulty)' gdzie
     - 'grid::Matrix{Int64}': Wygenerowana łamigłówka Sudoku z usuniętą określoną liczbą komórek.
     - 'difficulty::Int': Rzeczywisty poziom trudności wygenerowanej łamigłówki, dostosowany na podstawie liczby usuniętych komórek.

# Przykład
```jldoctest
julia> grid = [
    1  4  7  2  5  8  3  6  9;
    2  5  8  3  6  9  4  7  1;
    3  6  9  4  7  1  5  8  2;
    4  7  1  5  8  2  6  9  3;
    5  8  2  6  9  3  7  1  4;
    6  9  3  7  1  4  8  2  5;
    7  1  4  8  2  5  9  3  6;
    8  2  5  9  3  6  1  4  7;
    9  3  6  1  4  7  2  5  8
]
julia> removed_grid, difficulty = remove_cells(grid, 20, 81)
([1 4 … 6 9; 2 0 … 0 1; … ; 0 0 … 4 7; 0 0 … 5 0], 61)
julia> removed_grid
9x9 Matrix{Int64}:
 1  4  7  2  5  0  3  6  9
 2  0  8  3  6  9  0  0  1
 3  6  9  4  7  1  5  0  2
 4  7  1  5  8  2  6  9  3
 5  8  2  6  0  3  7  1  4
 6  9  0  0  1  0  8  2  0
 7  0  4  8  2  0  9  3  0
 0  0  0  9  3  6  1  4  7
 0  0  6  0  4  7  2  5  0
julia> difficulty
61
```
"""
function remove_cells(grid::Matrix{Int64}, num_cells_to_remove::Int, initial_difficulty::Int)
    flook = zeros(Bool, 9, 9)
    iterator = 0
    difficulty = initial_difficulty
    cells_removed = 0
        
    while cells_removed < num_cells_to_remove
        i, j = rand(1:9), rand(1:9)
        if !flook[i, j]
            iterator += 1
            flook[i, j] = true

            temp = grid[i, j]
            grid[i, j] = 0
            difficulty -= 1

            solutions = count_solutions(deepcopy(grid), limit=2)

            if solutions != 1
                grid[i, j] = temp
                difficulty += 1
            else
                cells_removed += 1
            end
        end

        if iterator >= 81
            grid = deepcopy(transformed_grid)
            fill!(flook, false)
            iterator = 0
            cells_removed = 0
            difficulty = initial_difficulty
        end
    end

    return grid, difficulty
end




"""
    count_solutions(grid::Matrix{Int64}; limit::Int=2)

Zlicza liczbę rozwiązań dla danej łamigłowki Sudoku.

# Argumenty
- 'grid::Matrix{Int64}': Siatka Sudoku reprezentowana jako macierz liczb całkowitych 9x9.
- 'limit::Int': (opcjonalnie) Maksymalna liczba rozwiązań do zliczenia. Wartość domyślna to 2.
    
# Zwraca
- 'solutions::Int': Liczba znalezionych rozwiązań dla łamigłówki Sudoku, aż do określonego 'limitu'.

# Przykład
```jldoctest
julia> grid = [
    1  4  7  2  5  0  3  6  9
    2  0  8  3  6  9  0  0  1
    3  6  9  4  7  1  5  0  2
    4  7  1  5  8  2  6  9  3
    5  8  2  6  0  3  7  1  4
    6  9  0  0  1  0  8  2  0
    7  0  4  8  2  0  9  3  0
    0  0  0  9  3  6  1  4  7
    0  0  6  0  4  7  2  5  0
]
julia> count_solutions(grid, limit=2)
1
```
"""
function count_solutions(grid::Matrix{Int64}; limit::Int=2)
    row, col = find_empty_cell(grid)

    if row == 0 && col == 0
        return 1
    end

    solutions = 0
    for num in 1:9
        if is_valid_sudoku(grid, row, col, num)
            grid[row, col] = num
            solutions += count_solutions(grid, limit=limit)

            if solutions >= limit
                break
            end

            grid[row, col] = 0
        end
    end

    return solutions
end



"""
    is_grid_filled(randomly_filled)

Sprawdza czy siatka Sudoku 'randomly_filled' jest w pełni wypełniona.
    
# Argumenty
- 'randomly_filled': Macierz 9x9 wartości logicznych reprezentująca wypełnione komórki w siatce Sudoku.
    
# Zwraca
- `filled::Bool`:
     - `true` jeśli wszystkie komórki w siatce są wypełnione.
     - `false` w przeciwym razie.

# Pzykład
```jldoctest
julia> randomly_filled = [
        true  false  false true true  false false false true;
        false  false false true  true  true  false false false;
        false true  true  false false true false true  false;
        true  false false false true  false false false true;
        true  false false true  false true  false false true;
        true  false false false true  false false false true;
        false true  false true false false true  true  false;
        false false false true  true  true  false false false;
        false true false false true  false false true  false
    ]
    
julia> is_filled = is_grid_filled(randomly_filled)
false
```
"""
function is_grid_filled(randomly_filled)
    for i in 1:9
        for j in 1:9
            if randomly_filled[i, j] == false
                return false
            end
        end
    end
    return true
end


"""
    find_empty_cell(grid::Matrix{Int64})

Znajduje współrzędne następnej pustej komórki w siatce Sudoku.
    
# Argumenty
- 'grid::Matrix{Int64}': Siatka Sudoku reprezentowana jako macierz liczb całkowitych 9x9.
   
# Zwraca
- 'wiersz::Int': Indeks wiersza następnej pustej komórki. 
- 'col::Int': Indeks kolumny następnej pustej komórki.
- Zwraca '(0, 0)', jeśli nie zostanie znaleziona pusta komórka.

# Przykład
```jldoctest
julia> grid = [
    1  4  7  2  5  0  3  6  9;
    2  0  8  3  6  9  0  0  1;
    3  6  9  4  7  1  5  0  2;
    4  7  1  5  8  2  6  9  3;
    5  8  2  6  0  3  7  1  4;
    6  9  0  0  1  0  8  2  0;
    7  0  4  8  2  0  9  3  0;
    0  0  0  9  3  6  1  4  7;
    0  0  6  0  4  7  2  5  0
]
    
julia> find_empty_cell(grid)
(1, 6)
```
"""
function find_empty_cell(grid::Matrix{Int64})
    for i in 1:9
        for j in 1:9
            if grid[i, j] == 0
                return i, j
            end
        end
    end

    return 0, 0
end

current_grid = zeros(Int64, 9, 9)
solved_grid = zeros(Int64, 9, 9)




"""
    find_empty_cell(grid::Matrix{Int64})

Generuje siatkę Sudoku z określoną trudnością.

# Argumenty
- 'difficulty::String': Poziom trudności siatki Sudoku do wygenerowania. Prawidłowe opcje to "easy", "medium" i "hard".
    
# Zwraca
- `generated_grid::Matrix{Int64}`: Wygenerowana łamigłówka Sudoku.

# Przykład
```jldoctest
julia> generate_sudoku("medium")
9x9 Matrix{Int64}:
 6  0  9  0  0  0  0  0  2
 5  2  8  0  3  0  0  0  0
 4  0  7  5  2  8  6  3  9
 8  0  0  0  6  3  1  0  4
 0  0  0  8  0  2  9  0  3
 0  0  0  0  0  4  2  0  0
 1  0  0  2  0  5  3  0  0
 3  0  6  0  1  7  0  2  8
 0  0  5  0  9  6  4  0  7
```
"""
function generate_sudoku(difficulty::String)
    base_grid = fully_solved_grid()
    transformed_grid = transform_grid(base_grid)

    initial_numbers = 0
    if difficulty == "easy"
        initial_numbers = 51
    elseif difficulty == "medium"
        initial_numbers = 41
    elseif difficulty == "hard"
        initial_numbers = 31
    end

    num_cells_to_remove = 81 - initial_numbers
    generated_grid, _ = remove_cells(transformed_grid, num_cells_to_remove, 81)

    return generated_grid
end


#Funkcja usuwa tekst z przycisków siatki reprezentowanej przez macierz przycisków GtkButton.
function clear_cells(cells::Matrix{GtkButton})
    for i in 1:9
        for j in 1:9
            set_gtk_property!(cells[i, j], :label, "")
        end
    end
end

# Funkcja zwraca liczbę dostępnych podpowiedzi w zależności od poziomu trudności. 
#Dla poziomu 0 zwraca 3, dla poziomu 1 zwraca 1, a dla innych poziomów zwraca 0.
function get_hint_count(difficulty)
    if difficulty == 0
        return 3
    elseif difficulty == 1
        return 1
    else
        return 0
    end
end

# Funkcja ustawia liczbę żyć w zależności od poziomu trudności. Dla poziomu 0 ustawia 3 życia,
#' dla poziomu 1 ustawia 1 życie, a dla innych poziomów ustawia 0 żyć.
function set_lives(difficulty)
    if difficulty == 0
        return 3
    elseif difficulty == 1
        return 1
    else
        return 0
    end
end


# Funkcja aktualizuje etykietę z ilością żyć
function update_lives_label(lives_label::GtkLabel, lives_count)
    if(lives[]<0) set_gtk_property!(lives_label, :label, "Życia: 0")
    
    else
    set_gtk_property!(lives_label, :label, "Życia: $lives_count")
    end
end

# Funkcja dodaje separator do siatki
function add_separator(grid::GtkGrid, row::Int, col::Int)
    separator = Gtk.Box(:v)
    set_gtk_property!(separator, :width_request, 5)
    set_gtk_property!(separator, :height_request, 5)
    grid[row, col] = separator
end

# Funkcja dodaje separator poziomy do siatki
function add_horizontal_separator(grid::GtkGrid, row::Int, col::Int)
    separator = Gtk.Box(:h)
    set_gtk_property!(separator, :width_request, 5)
    set_gtk_property!(separator, :height_request, 5)
    grid[row, col] = separator
end



# Funkcja pokazuje okno dialogowe z wiadomością
function show_message_dialog(parent, message, title)
    dialog = GtkWindow(title, 200, 100)
    vbox = GtkBox(:v)
    label = GtkLabel(message)
    close_button = GtkButton("Zakończ")

    push!(vbox, label)
    push!(vbox, close_button)

    signal_connect(close_button, "clicked") do widget
        destroy(dialog)
    end

    push!(dialog, vbox)
    showall(dialog)
end

randomly_filled = Matrix{Bool}(undef, 9, 9)
fill!(randomly_filled, false)
current_grid = zeros(Int64, 9, 9)
solved_grid = zeros(Int64, 9, 9)


# Inicjalizacja pustych siatek i rozwiązanej siatki
function fill_random_cells(cells::Matrix{GtkButton}, grid::Matrix{Int64}, randomly_filled::Matrix{Bool})
    for i in 1:9
        for j in 1:9
            if grid[i, j] != 0
                set_gtk_property!(cells[i, j], :label, string(grid[i, j]))
                randomly_filled[i, j] = true
            else
                randomly_filled[i, j] = false
            end
        end
    end
end
function insert_random_cell(cells::Matrix{GtkButton}, grid::Matrix{Int64}, solved_grid::Matrix{Int64})
    unfilled = [(i, j) for i in 1:9, j in 1:9 if !randomly_filled[i, j]]
    if isempty(unfilled)
        return
    end
    i, j = rand(unfilled)

    selected_number = solved_grid[i, j]
    set_gtk_property!(cells[i, j], :label, string(selected_number))
    grid[i, j] = selected_number
    randomly_filled[i, j] = true
end

win = GtkWindow("Menu", 200, 200)
btn_start = GtkButton("Start")
btn_settings = GtkButton("Ustawienia")
autors_btn = GtkButton("O autorach")
rules_btn = GtkButton("Zasady gry")
vbox = GtkBox(:v)
push!(vbox, btn_start)
push!(vbox, btn_settings)
push!(vbox, autors_btn)
push!(vbox,rules_btn)
push!(win, vbox)


window = GtkWindow("Sudoku", 600, 400)
Gtk.fullscreen(window)
vbox = GtkBox(:v)
hbox = GtkBox(:h)
sudoku_back_btn = GtkButton("Powrót")
push!(vbox, sudoku_back_btn)
push!(window, vbox)
hide(window)
buttons_box = GtkBox(:h)
grid = GtkGrid(column_homogeneous=true, row_homogeneous=true)
new_game_button = GtkButton("Nowa gra")
quit_button = GtkButton("Zakończ")
hint_button = GtkButton("Podpowiedź")
lives_label = GtkLabel("Życia: 0")
push!(vbox, lives_label)
cell_buttons = Matrix{GtkButton}(undef, 9, 9)
# Tworzenie siatki przycisków
for i in 1:9
    for j in 1:9
        button = GtkButton("")
        set_gtk_property!(button, :hexpand, true)
        set_gtk_property!(button, :vexpand, true)
        row = i + div(i - 1, 3)
        col = j + div(j - 1, 3)
        grid[row, col] = button
        cell_buttons[i, j] = button
    end
end

# Dodawanie separatorów do siatki
for j in (4, 7)
    for i in 1:11
        add_separator(grid, i, j)
    end
end
for i in (4, 7)
    for j in 1:11
        add_horizontal_separator(grid, i, j)
    end
end

# Dodawanie siatki i przycisków do pudełka
push!(vbox, grid)
push!(vbox, buttons_box)
push!(buttons_box, hbox)
number_buttons_box = GtkBox(:h)
number_buttons = Vector{GtkButton}(undef, 9)

# Tworzenie przycisków numerycznych
for i in 1:9
    button = GtkButton(string(i))
    set_gtk_property!(button, :hexpand, true)
    set_gtk_property!(button, :vexpand, false)
    push!(number_buttons_box, button)
    number_buttons[i] = button
end

clear_button = GtkButton("Wyczyść")
push!(hbox, clear_button)
push!(hbox, new_game_button)
push!(hbox, quit_button)
push!(hbox, hint_button)
push!(buttons_box, number_buttons_box)

# Wybór poziomu trudności
difficulty_list = GtkComboBoxText()
for difficulty in ["Łatwy", "Średni", "Trudny"]
    push!(difficulty_list, difficulty)
end
set_gtk_property!(difficulty_list, :active, 0)
push!(vbox, difficulty_list)
push!(window, vbox)
set_gtk_property!(window, :border_width, 20)

# Zmienne pomocnicze
selected_number = Ref(0)
clear_mode = Ref(false)

# Sygnały dla przycisków numerycznych
for i in 1:9
    signal_connect(number_buttons[i], "clicked") do widget
        selected_number[] = i
        clear_mode[] = false
    end
end
for i in 1:9
    for j in 1:9
        button = cell_buttons[i, j]
        signal_connect(button, "clicked") do widget
            if lives[] > -1
            if clear_mode[]
                if !randomly_filled[i, j]
                    set_gtk_property!(button, :label, "")
                    randomly_filled[i, j] = false
                end
            elseif selected_number[] != 0 && !randomly_filled[i, j]
                if solved_grid[i, j] == selected_number[]
                    set_gtk_property!(button, :label, string(selected_number[]))
                    randomly_filled[i, j] = true
                    if is_grid_filled(randomly_filled)
                        show_message_dialog(window, "Zwycięstwo", "Gratulacje!")
                    end
                else
                    lives[] -= 1
                    update_lives_label(lives_label, lives[])
                    if lives[] < 0
                        show_message_dialog(window, "Przegrana", "Spróbuj ponownie!")
                    else
                        show_message_dialog(window, "Niepoprawna liczba.")
                        set_gtk_property!(button, :label, "")
                    end
                end
            end
        end
        end
    end
end

# Sygnał dla przycisku "Wyczyść"
signal_connect(clear_button, "clicked") do widget
    clear_mode[] = !clear_mode[]
end

# Sygnały dla przycisków numerycznych
selected_number = Ref(0)
for i in 1:9
    signal_connect(number_buttons[i], "clicked") do widget
        selected_number[] = i
    end
end

# Podpowiedzi i poziom trudności
lives = Ref(3)
hint_count = Ref(0)
difficulty = 0
update_lives_label(lives_label, difficulty)


# Sygnały dla przycisków gry
signal_connect(new_game_button, "clicked") do widget
    global solved_grid
    clear_cells(cell_buttons)
    difficulty = get_gtk_property(difficulty_list, :active, Int)
    lives[] = set_lives(difficulty)
    update_lives_label(lives_label, lives[])
    hint_count[] = get_hint_count(difficulty)
    if difficulty == 0
        current_grid = generate_sudoku("easy") 
        fill_random_cells(cell_buttons, current_grid, randomly_filled)
    elseif difficulty == 1
        current_grid = generate_sudoku("medium") 
        fill_random_cells(cell_buttons, current_grid, randomly_filled)
    elseif difficulty == 2
        current_grid = generate_sudoku("hard") 
        fill_random_cells(cell_buttons, current_grid, randomly_filled)
    end
    solved_grid = solve_sudoku(current_grid)[2] 
end
signal_connect(hint_button, "clicked") do widget
    if hint_count[] > 0
        insert_random_cell(cell_buttons, current_grid, solved_grid)
        hint_count[] -= 1
    end
end


# Sygnał dla przycisku "Zakończ"
signal_connect(quit_button, "clicked") do widget
    destroy(window)
end

signal_connect(window, :delete_event) do _
    hide(window)
    showall(win)
    true
end


settings_win = GtkWindow("Ustawienia", 300, 300)
settings_vbox = GtkBox(:v)
autors_vbox =GtkBox(:v)
rules_vbox = GtkBox(:v)
settings_back_btn = GtkButton("Powrót")
push!(settings_vbox, settings_back_btn)
push!(settings_win, settings_vbox)
hide(settings_win)
autors_win = GtkWindow("O autorach", 300, 300)
autors_back_btn = GtkButton("Powrót")
push!(autors_vbox, autors_back_btn)
label1 = GtkLabel("Studenci Matematyki Stosowanej na Politechnice Wrocławskiej")
push!(autors_vbox, label1)
push!(autors_win, autors_vbox)
hide(autors_win)
rules_win = GtkWindow("Zasady",500,500)
rules_back_btn= GtkButton("Powrót")
label3 = GtkLabel("Zasady gry Sudoku są niezwykle proste. Kwadratowa plansza jest podzielona na dziewięć identycznych kwadratów 3 x 3 - 
w każdym z nich znajduje się dziewięć komórek.Twoim zadaniem jest wypełnienie wszystkich komórek planszy cyframi od 1 do 9. 
W każdym wierszu i każdej kolumnie dana cyfra może występować jedynie raz.Twoim zadaniem jest wypełnienie wszystkich komórek 
planszy cyframi od 1 do 9. W każdym wierszu i każdej kolumnie dana cyfra może występować jedynie raz.Twoim zadaniem jest
 wypełnienie wszystkich komórek planszy cyframi od 1 do 9. W każdym wierszu i każdej kolumnie dana cyfra może występować
  jedynie raz.Podobnie w każdym z dziewięciu kwadratów 3 x 3 - cyfry nie mogą się powtarzać.Podobnie w każdym z dziewięciu
   kwadratów 3 x 3 - cyfry nie mogą się powtarzać.")
push!(rules_vbox,rules_back_btn)
push!(rules_vbox,label3)
push!(rules_win, rules_vbox)
hide(rules_win)
signal_connect(settings_win, :delete_event) do _
    hide(settings_win)
    showall(win)
    true
end
signal_connect(autors_win, :delete_event) do _
    hide(autors_win)
    showall(win)
    true
end
signal_connect(rules_win, :delete_event) do _
    hide(rules_win)
    showall(win)
    true
end
signal_connect(btn_start, "clicked") do widget
    hide(win)
    showall(window)
end
signal_connect(btn_settings, "clicked") do widget
    hide(win)
    showall(settings_win)
end
signal_connect(autors_btn, "clicked") do widget
    hide(win)
    showall(autors_win)
end
signal_connect(rules_btn, "clicked") do widget
    hide(win)
    showall(rules_win)
end
signal_connect(sudoku_back_btn, "clicked") do widget
    hide(window)
    showall(win)
end
signal_connect(settings_back_btn, "clicked") do widget
    hide(settings_win)
    showall(win)
end
signal_connect(autors_back_btn, "clicked") do widget
    hide(autors_win)
    showall(win)
end
signal_connect(rules_back_btn, "clicked") do widget
    hide(rules_win)
    showall(win)
end
showall(win)
Gtk.gtk_main()