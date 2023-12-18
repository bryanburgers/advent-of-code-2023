use std::collections::HashSet;

fn main() {
    let file = std::env::args()
        .into_iter()
        .skip(1)
        .next()
        .expect("Expecting file name");
    let data = std::fs::read(file).unwrap();
    let data = Vec::leak(data);
    let board = Board::new(data);

    let start_entry = Entry::new(Point { x: 0, y: 0 }, Direction::WestToEast);
    let mut entry_stack: Vec<Entry> = vec![Entry::new(Point { x: 0, y: 0 }, Direction::WestToEast)];
    let mut entries_seen: HashSet<Entry> = Default::default();
    entries_seen.insert(start_entry);
    let mut points_seen: HashSet<Point> = Default::default();
    points_seen.insert(start_entry.point);

    while let Some(entry) = entry_stack.pop() {
        let mut exit_controller = |new_direction| {
            let new_point = entry.point.in_direction(new_direction);
            if !new_point.is_in_board(&board) {
                return;
            }

            let new_entry = Entry::new(new_point, new_direction);
            if entries_seen.insert(new_entry) {
                entry_stack.push(new_entry);
                points_seen.insert(new_point);
            }
        };
        board.exits(entry.point, entry.direction, &mut exit_controller);
    }

    println!("{}", points_seen.len());
}

#[derive(Debug)]
struct Board {
    data: &'static [u8],
    width: i16,
    height: i16,
}

impl Board {
    fn new(data: &'static [u8]) -> Self {
        let (width, _) = data
            .iter()
            .enumerate()
            .find(|(_, byte)| **byte == b'\n')
            .unwrap();

        let height = data.len() / (width + 1);
        Self {
            data,
            width: width as i16,
            height: height as i16,
        }
    }

    fn byte_at(&self, point: Point) -> u8 {
        let idx = (self.width + 1) * point.y + point.x;
        self.data[idx as usize]
    }

    fn exits(&self, point: Point, direction: Direction, exit_controller: &mut impl ExitController) {
        match (self.byte_at(point), direction) {
            (b'.', _)
            | (b'|', Direction::NorthToSouth | Direction::SouthToNorth)
            | (b'-', Direction::WestToEast | Direction::EastToWest) => {
                exit_controller.exit(direction);
            }
            (b'|', Direction::WestToEast | Direction::EastToWest) => {
                exit_controller.exit(Direction::SouthToNorth);
                exit_controller.exit(Direction::NorthToSouth);
            }
            (b'-', Direction::NorthToSouth | Direction::SouthToNorth) => {
                exit_controller.exit(Direction::WestToEast);
                exit_controller.exit(Direction::EastToWest);
            }
            (b'/', Direction::WestToEast) => {
                exit_controller.exit(Direction::SouthToNorth);
            }
            (b'/', Direction::NorthToSouth) => {
                exit_controller.exit(Direction::EastToWest);
            }
            (b'/', Direction::EastToWest) => {
                exit_controller.exit(Direction::NorthToSouth);
            }
            (b'/', Direction::SouthToNorth) => {
                exit_controller.exit(Direction::WestToEast);
            }
            (b'\\', Direction::WestToEast) => {
                exit_controller.exit(Direction::NorthToSouth);
            }
            (b'\\', Direction::NorthToSouth) => {
                exit_controller.exit(Direction::WestToEast);
            }
            (b'\\', Direction::EastToWest) => {
                exit_controller.exit(Direction::SouthToNorth);
            }
            (b'\\', Direction::SouthToNorth) => {
                exit_controller.exit(Direction::EastToWest);
            }
            (byte, _) => panic!("Unexpected byte '{byte}'",),
        }
    }
}

trait ExitController {
    fn exit(&mut self, direction: Direction);
}

impl<F> ExitController for F
where
    F: FnMut(Direction) -> (),
{
    fn exit(&mut self, direction: Direction) {
        self(direction)
    }
}

#[derive(Debug, Copy, Clone, Eq, PartialEq, Hash)]
struct Point {
    x: i16,
    y: i16,
}

impl Point {
    fn in_direction(self, direction: Direction) -> Self {
        match direction {
            Direction::WestToEast => Self {
                x: self.x + 1,
                y: self.y,
            },
            Direction::NorthToSouth => Self {
                x: self.x,
                y: self.y + 1,
            },
            Direction::EastToWest => Self {
                x: self.x - 1,
                y: self.y,
            },
            Direction::SouthToNorth => Self {
                x: self.x,
                y: self.y - 1,
            },
        }
    }

    fn is_in_board(&self, board: &Board) -> bool {
        self.x >= 0 && self.x < board.width && self.y >= 0 && self.y < board.height
    }
}

#[derive(Debug, Copy, Clone, Eq, PartialEq, Hash)]
enum Direction {
    WestToEast,
    NorthToSouth,
    EastToWest,
    SouthToNorth,
}

#[derive(Debug, Copy, Clone, Eq, PartialEq, Hash)]
struct Entry {
    point: Point,
    direction: Direction,
}

impl Entry {
    fn new(point: Point, direction: Direction) -> Self {
        Entry { point, direction }
    }
}
