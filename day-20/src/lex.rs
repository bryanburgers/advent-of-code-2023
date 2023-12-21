use winnow::{
    ascii::{alpha1, space0},
    combinator::{alt, preceded, repeat, terminated},
    prelude::*,
};

#[derive(Debug, Copy, Clone, Eq, PartialEq)]
pub enum Token<'a> {
    Identifier(&'a str),
    Arrow,
    Comma,
    Percent,
    Ampersand,
    EOL,
}

impl<'a> Token<'a> {
    pub fn lex(input: &'a str) -> Result<Vec<Token<'a>>, String> {
        lex(input)
    }
}

fn lex<'a>(input: &'a str) -> Result<Vec<Token<'a>>, String> {
    lex_top.parse(input).map_err(|e| e.to_string())
}

fn lex_top<'a>(input: &mut &'a str) -> PResult<Vec<Token<'a>>> {
    preceded(space0, repeat(0.., terminated(token, space0))).parse_next(input)
}

fn token<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    alt([eol, identifier, arrow, comma, percent, ampersand]).parse_next(input)
}

fn eol<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    "\n".value(Token::EOL).parse_next(input)
}
fn identifier<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    alpha1.map(Token::Identifier).parse_next(input)
}
fn arrow<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    "->".value(Token::Arrow).parse_next(input)
}
fn comma<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    ",".value(Token::Comma).parse_next(input)
}
fn percent<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    "%".value(Token::Percent).parse_next(input)
}
fn ampersand<'a>(input: &mut &'a str) -> PResult<Token<'a>> {
    "&".value(Token::Ampersand).parse_next(input)
}

impl<'a> winnow::stream::ContainsToken<Token<'a>> for Token<'a> {
    fn contains_token(&self, token: Token) -> bool {
        *self == token
    }
}

impl<'a> winnow::stream::ContainsToken<Token<'a>> for &'_ [Token<'a>] {
    fn contains_token(&self, token: Token) -> bool {
        self.iter().any(|t| *t == token)
    }
}

impl<'a, const LEN: usize> winnow::stream::ContainsToken<Token<'a>> for &'_ [Token<'a>; LEN] {
    fn contains_token(&self, token: Token) -> bool {
        self.iter().any(|t| *t == token)
    }
}

impl<'a, const LEN: usize> winnow::stream::ContainsToken<Token<'a>> for [Token<'a>; LEN] {
    fn contains_token(&self, token: Token) -> bool {
        self.iter().any(|t| *t == token)
    }
}
