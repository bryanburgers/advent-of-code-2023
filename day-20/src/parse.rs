use crate::lex::Token;
use winnow::{
    combinator::{alt, opt, repeat, separated, terminated},
    prelude::*,
    seq,
    token::one_of,
};

#[derive(Debug)]
pub struct Ast<'a> {
    pub lines: Vec<AstLine<'a>>,
}

impl<'a> Ast<'a> {
    pub fn parse(input: &'a str) -> Result<Ast<'a>, String> {
        let tokens = Token::lex(input)?;
        parse(&tokens)
    }
}

#[derive(Debug)]
pub struct AstLine<'a> {
    pub source: Source<'a>,
    pub destinations: Vec<Identifier<'a>>,
}

#[derive(Debug)]
pub struct Identifier<'a>(pub &'a str);

#[derive(Debug)]
pub struct Source<'a> {
    pub ty: Type,
    pub identifier: Identifier<'a>,
}

#[derive(Debug)]
pub enum Type {
    None,
    FlipFlop,
    Conjunction,
}

fn parse<'a>(tokens: &[Token<'a>]) -> Result<Ast<'a>, String> {
    parse_input.parse(tokens).map_err(|e| format!("{e:?}"))
}

fn parse_input<'a>(input: &mut &[Token<'a>]) -> PResult<Ast<'a>> {
    let lines = repeat(0.., terminated(parse_line, one_of(Token::EOL))).parse_next(input)?;
    Ok(Ast { lines })
}

fn parse_line<'a>(input: &mut &[Token<'a>]) -> PResult<AstLine<'a>> {
    seq!(AstLine {
        source: parse_source,
        _: one_of(Token::Arrow),
        destinations: separated(1.., parse_identifier, one_of(Token::Comma))
    })
    .parse_next(input)
}

fn parse_source<'a>(input: &mut &[Token<'a>]) -> PResult<Source<'a>> {
    seq! {
        Source {
            ty: parse_type,
            identifier: parse_identifier,
        }
    }
    .parse_next(input)
}

fn parse_type(input: &mut &[Token<'_>]) -> PResult<Type> {
    let result = opt(alt([parse_flip_flop, parse_conjunction])).parse_next(input)?;
    Ok(result.unwrap_or(Type::None))
}

fn parse_flip_flop(input: &mut &[Token<'_>]) -> PResult<Type> {
    one_of(Token::Percent)
        .map(|_| Type::FlipFlop)
        .parse_next(input)
}

fn parse_conjunction(input: &mut &[Token<'_>]) -> PResult<Type> {
    one_of(Token::Ampersand)
        .map(|_| Type::Conjunction)
        .parse_next(input)
}

fn parse_identifier<'a>(input: &mut &[Token<'a>]) -> PResult<Identifier<'a>> {
    one_of(|item| matches!(item, Token::Identifier(_)))
        .map(|token| match token {
            Token::Identifier(identifier) => Identifier(identifier),
            _ => unreachable!(),
        })
        .parse_next(input)
}
